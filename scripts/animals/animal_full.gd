extends State
class_name  AnimalFull

@export var animal:CharacterBody2D
@onready var interaction:AnimatedSprite2D = $"../../Action"
@onready var area:Area2D = $"../../InteractionRange"
@onready var ui:Control = $"../../FeedingUi"
@onready var kill_btn = $"../../FeedingUi/Menu/Schlachten"
@onready var interact_btn = $"../../FeedingUi/Menu/Interact"
@onready var interact_range = $"../../InteractionRange"
@onready var sprite_frames:SpriteFrames = $"../../AnimatedSprite2D".sprite_frames
@onready var player:AnimatedSprite2D = $"../../AnimatedSprite2D"
@onready var cage = get_parent().get_parent().get_parent()


var selection_highlight: NinePatchRect = null

var in_area:bool = false
var ui_shown:bool = false
var should_show:bool = false


func _ready() -> void:
	match animal.name.to_lower().rstrip("1234567890"):
		"cow":
			interact_btn.text = "Milk Cow"
		"chicken":
			interact_btn.text = "Collect Eggs"
		"sheep":
			interact_btn.text = "Shear Sheep"
	_setup_highlight()
	kill_btn.pressed.connect(on_kill)
	interact_btn.pressed.connect(on_interaction)
	cage.want_to_interact.connect(on_harvest)
	interact_range.mouse_entered.connect(_on_mouse_entered)
	interact_range.mouse_exited.connect(_on_mouse_exited)

	
func enter():
	if cage.want_to_interact.get_connections().size() < 1:
		cage.want_to_interact.connect(on_harvest)
	interaction.visible = true
	interaction.play("full")

func process_input(_event: InputEvent):
	if _event.is_action_pressed("interact2") && in_area && should_show:
		if ui_shown:
			ui.hide()
			ui_shown = false
		else:
			ui.show()
			ui_shown = true
			
func _setup_highlight() -> void:
	var tex = sprite_frames.get_frame_texture(player.animation, player.frame)
	selection_highlight = NinePatchRect.new()
	selection_highlight.name = "SelectionHighlight"
	#selection_highlight.texture = preload("res://assets/gui/menu.png")
	selection_highlight.region_rect = Rect2(305, 81, 14, 14)
	selection_highlight.mouse_filter = Control.MOUSE_FILTER_IGNORE
	selection_highlight.modulate = Color(1, 1, 1, 0.4)
	selection_highlight.visible = false
	selection_highlight.size = tex.get_size() * player.get_scale()
	selection_highlight.position = Vector2(-64, -64)
	animal.add_child.call_deferred(selection_highlight)
	
			
func on_kill():
	get_parent().get_parent().get_parent().get_node("FeedingThrough").cow_positions.append(animal.position)
	SaveGame.add_to_inventory(animal.name.to_lower().rstrip("1234567890") + "_meat", 2)
	get_parent().get_parent().queue_free()
	
func on_interaction():
	var animal_type = animal.name.to_lower().rstrip("1234567890")
	match animal_type:
		"cow":
			SaveGame.add_to_inventory("milk", 1)
		"chicken":
			SaveGame.add_to_inventory("egg", 1)
		"sheep":
			SaveGame.add_to_inventory("white_wool", 1)
	
	print(SaveGame.get_inventory())
	transitioned.emit(self, "Hungry")
		
func exit():
	should_show = false
	interaction.visible = false
	ui.hide()
		
func _on_mouse_entered() -> void:
	if should_show && get_parent().current_state is AnimalFull:
		selection_highlight.visible = true
	in_area = true

func _on_mouse_exited() -> void:
	in_area = false
	selection_highlight.visible = false
	
func on_harvest(begin:bool) -> void:
	should_show = begin
	if !begin:
		selection_highlight.visible = false
