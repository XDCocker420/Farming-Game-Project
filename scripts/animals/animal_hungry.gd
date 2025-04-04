extends State
class_name  AnimalHungry

@export var animal:CharacterBody2D
@onready var player:AnimatedSprite2D = $"../../AnimatedSprite2D"
@onready var animal_area = get_parent().get_parent().get_parent()
@onready var interact_range:Area2D = $"../../InteractionRange"
@onready var sprite_frames:SpriteFrames = $"../../AnimatedSprite2D".sprite_frames

var feeding:bool = false
var selection_highlight:NinePatchRect = null
var in_area:bool = false

func _ready() -> void:
	_setup_highlight()
	animal_area.feeding_state.connect(_on_feeding)
	animal_area.collecting_state.connect(_on_switch)
	interact_range.mouse_entered.connect(_on_mouse_entered)
	interact_range.mouse_exited.connect(_on_mouse_exited)
	
func process_input(_event: InputEvent):
	if _event is InputEventMouseButton && _event.is_pressed() && _event.button_index == MOUSE_BUTTON_LEFT && in_area && feeding && SaveGame.get_item_count(get_parent().get_parent().name.to_lower()) >= 1:
		transitioned.emit(self, "fed")

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

func _on_feeding():
	#SaveGame.add_to_inventory("cow")
	feeding = true
	
func _on_switch():
	feeding = false
	
func _on_mouse_entered() -> void:
	if get_parent().current_state is AnimalHungry && feeding && SaveGame.get_item_count(get_parent().get_parent().name.to_lower()+"_food") >= 1:
		selection_highlight.visible = true
	in_area = true

func _on_mouse_exited() -> void:
	in_area = false
	selection_highlight.visible = false
	
func enter():
	if animal:
		player.play("sleep")
		
func exit():
	selection_highlight.visible = false
	feeding = false
