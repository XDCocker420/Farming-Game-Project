extends State
class_name  AnimalFull

@export var animal:CharacterBody2D
@onready var interaction:AnimationPlayer = $"../../Action"
@onready var area:Area2D = $"../../InteractionRange"
@onready var interact_range = $"../../InteractionRange"
@onready var sprite_frames:SpriteFrames = $"../../AnimatedSprite2D".sprite_frames
@onready var player:AnimatedSprite2D = $"../../AnimatedSprite2D"
@onready var animal_area = get_parent().get_parent().get_parent()
@onready var sprite:Sprite2D = $"../../Sprite2D"


var selection_highlight: NinePatchRect = null
var collect:bool = false

var in_area:bool = false

func _ready() -> void:
	_setup_highlight()
	animal_area.collecting_state.connect(_on_collection)
	animal_area.feeding_state.connect(_on_switch)
	interact_range.mouse_entered.connect(_on_mouse_entered)
	interact_range.mouse_exited.connect(_on_mouse_exited)

func _on_switch():
	collect = false

func _on_collection():
	collect = true
	
func enter():
	player.play("sleep")
	sprite.visible = true
	interaction.play("interaction")
	
func _translate(name:String):
	match name:
		"cow":
			return "milk"
		"chicken":
			return "egg"
		"sheep":
			return "white_wool"
		"pig":
			return "meat"

func process_input(_event: InputEvent):
	if _event is InputEventMouseButton && _event.is_pressed() && _event.button_index == MOUSE_BUTTON_LEFT && in_area && collect:
		SaveGame.add_to_inventory(_translate(animal.name.to_lower().rstrip("1234567890")))
		
		transitioned.emit(self, "Hungry")
			
func _setup_highlight() -> void:
	var tex = sprite_frames.get_frame_texture(player.animation, player.frame)
	selection_highlight = NinePatchRect.new()
	selection_highlight.texture = preload("res://assets/ui/general/selected.png")
	selection_highlight.mouse_filter = Control.MOUSE_FILTER_IGNORE
	selection_highlight.modulate = Color(1, 1, 1, 0.4)
	selection_highlight.visible = false
	selection_highlight.size = tex.get_size() * player.get_scale()
	selection_highlight.position = Vector2(-12, -20)
	animal.add_child.call_deferred(selection_highlight)
		
func exit():
	sprite.visible = false
	collect = false
	
func _on_mouse_entered() -> void:
	if get_parent().current_state is AnimalFull && collect:
		selection_highlight.visible = true
	in_area = true

func _on_mouse_exited() -> void:
	in_area = false
	selection_highlight.visible = false
