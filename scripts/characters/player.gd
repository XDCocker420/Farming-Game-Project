extends CharacterBody2D


signal interact
signal interact2

@onready var animation_layers: Node = $animation_layers

@export var normal_speed: float = 50.0
@export var sprint_speed: float = 100.0
@export var cant_move: bool = false

var selected_crop: String = "carrot"  # Default crop
var looking_direction: String = "down"
var current_speed: float

var layers: Array


func _ready() -> void:
    # Add the player to the "Player" group for identification
    #load_state()
    reload_layers()
    current_speed = normal_speed


func _input(event: InputEvent) -> void:
    # Check if the interaction key is pressed
    if event.is_action_pressed("interact"):
        interact.emit()
        
    if event.is_action_pressed("interact2"):
        interact2.emit()

    # exit game on esc
    '''if event.is_action_pressed("ui_cancel"):
        get_tree().quit()'''


func set_selected_crop(crop_name: String) -> void:
    selected_crop = crop_name


func reload_layers():
    layers = animation_layers.get_children()


func _physics_process(_delta):
    if !cant_move:
        current_speed = sprint_speed if Input.is_action_pressed("sprint") else normal_speed
        
        var direction = Vector2.ZERO
        direction.x = Input.get_axis("move_left", "move_right")
        direction.y = Input.get_axis("move_up", "move_down")
        direction = direction.normalized()
        
        velocity = direction * current_speed

        if direction.x > 0:
            looking_direction = "right"
        elif direction.x < 0:
            looking_direction = "left"
        elif direction.y > 0:
            looking_direction = "down"
        elif direction.y < 0:
            looking_direction = "up"

        update_animation(direction)
        move_and_slide()


func update_animation(direction: Vector2):
    if direction != Vector2.ZERO:
        for layer in layers:
            layer.play("walk_" + looking_direction)
    else:
        for layer in layers:
            layer.stop()
