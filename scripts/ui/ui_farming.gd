extends PanelContainer

@onready var slot1:Button = $MarginContainer/HBoxContainer/PanelContainer/Button
@onready var slot2:Button = $MarginContainer/HBoxContainer/PanelContainer2/Button
@onready var slot3:Button = $MarginContainer/HBoxContainer/PanelContainer3/Button
@onready var slot4:Button = $MarginContainer/HBoxContainer/PanelContainer4/Button
@onready var slot5:Button = $MarginContainer/HBoxContainer/PanelContainer5/Button
@onready var slot6:Button = $MarginContainer/HBoxContainer/PanelContainer6/Button
@onready var slot7:Button = $MarginContainer/HBoxContainer/PanelContainer7/Button
@onready var slot8:Button = $MarginContainer/HBoxContainer/PanelContainer8/Button
@onready var slot9:Button = $MarginContainer/HBoxContainer/PanelContainer9/Button

@onready var panel1:PanelContainer = $MarginContainer/HBoxContainer/PanelContainer
@onready var panel2:PanelContainer = $MarginContainer/HBoxContainer/PanelContainer2
@onready var panel3:PanelContainer = $MarginContainer/HBoxContainer/PanelContainer3
@onready var panel4:PanelContainer = $MarginContainer/HBoxContainer/PanelContainer4
@onready var panel5:PanelContainer = $MarginContainer/HBoxContainer/PanelContainer5
@onready var panel6:PanelContainer = $MarginContainer/HBoxContainer/PanelContainer6
@onready var panel7:PanelContainer = $MarginContainer/HBoxContainer/PanelContainer7
@onready var panel8:PanelContainer = $MarginContainer/HBoxContainer/PanelContainer8
@onready var panel9:PanelContainer = $MarginContainer/HBoxContainer/PanelContainer9

@onready var panel = $MarginContainer/HBoxContainer/PanelContainer
@onready var hbox = $MarginContainer/HBoxContainer
@onready var mar_box:MarginContainer = $MarginContainer

var current_btn:Button = null
var items:Array[String] = ["wheat_seed", "corn_seed", "carrot_seed", "pumpkin_seed", "potatoe_seed", "tomatoe_seed", "lettuce_seed", "eggplant_seed", "melon_seed"]


var corelation:Dictionary

var selection_highlight:NinePatchRect
var selection:String = '':
	set(value):
		selection = value
		if current_btn:
			current_btn.remove_child(selection_highlight)

func _ready() -> void:
	_setup_highlight()
	
	corelation = {
	"wheat_seed": panel1,
	"corn_seed": panel2,
	"carrot_seed": panel3,
	"pumpkin_seed": panel4,
	"potatoe_seed": panel5,
	"tomatoe_seed": panel6,
	"lettuce_seed": panel7,
	"eggplant_seed": panel8,
	"melon_seed": panel9
}
	
	level_handling()
	visibility_changed.connect(_on_show)

	slot1.pressed.connect(_on_button_pressed)
	slot2.pressed.connect(_on_button2_pressed)
	slot3.pressed.connect(_on_button3_pressed)
	slot4.pressed.connect(_on_button4_pressed)
	slot5.pressed.connect(_on_button5_pressed)
	slot6.pressed.connect(_on_button6_pressed)
	slot7.pressed.connect(_on_button7_pressed)
	slot8.pressed.connect(_on_button8_pressed)
	slot9.pressed.connect(_on_button9_pressed)

	
func _setup_highlight() -> void:
	selection_highlight = NinePatchRect.new()
	selection_highlight.texture = preload("res://assets/ui/general/selected.png")
	selection_highlight.mouse_filter = Control.MOUSE_FILTER_IGNORE
	selection_highlight.modulate = Color(1, 1, 1, 0.4)
	selection_highlight.visible = false
	selection_highlight.size = Vector2(18,21)
	selection_highlight.z_index = 10

func level_handling():
	var unlocked:Array = LevelingHandler.get_all_unlocked_items()
	for i in corelation.keys():
		if i not in unlocked:
			corelation[i].modulate = Color(0.5,0.5,0.5)
			corelation[i].get_child(2).disabled = true
	
func _on_button_pressed():
	selection = 'wheat_seed'
	current_btn = slot1
	selection_highlight.visible = true
	slot1.add_child(selection_highlight)
	
	
func _on_button2_pressed():
	selection = 'corn_seed'
	current_btn = slot2
	selection_highlight.visible = true
	slot2.add_child(selection_highlight)
	
	
func _on_button3_pressed():
	selection = 'carrot_seed'
	current_btn = slot3
	selection_highlight.visible = true
	slot3.add_child(selection_highlight)
	
	
func _on_button4_pressed():
	selection = 'pumpkin_seed'
	current_btn = slot4
	selection_highlight.visible = true
	slot4.add_child(selection_highlight)
	
	
func _on_button5_pressed():
	selection = 'potatoe_seed'
	current_btn = slot5
	selection_highlight.visible = true
	slot5.add_child(selection_highlight)
	
	
func _on_button6_pressed():
	selection = 'tomatoe_seed'
	current_btn = slot6
	selection_highlight.visible = true
	slot6.add_child(selection_highlight)
	
	
func _on_button7_pressed():
	selection = 'lettuce_seed'
	current_btn = slot7
	slot7.add_child(selection_highlight)
	selection_highlight.visible = true
	
func _on_button8_pressed():
	selection = 'eggplant_seed'
	current_btn = slot8
	selection_highlight.visible = true
	slot8.add_child(selection_highlight)
	
	
func _on_button9_pressed():
	selection = 'melon_seed'
	current_btn = slot9
	selection_highlight.visible = true
	slot9.add_child(selection_highlight)
	
func _on_show():
	level_handling()
