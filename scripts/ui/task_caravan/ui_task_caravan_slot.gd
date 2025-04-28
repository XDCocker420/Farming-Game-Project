extends PanelContainer


signal selected(id: int, items_dict: Dictionary, money_reward: int, xp_reward: int)

@onready var button: TextureButton = $TextureButton
@onready var money_label: Label = $VBoxContainer/HBoxContainer/money_label
@onready var xp_label: Label = $VBoxContainer/HBoxContainer2/xp_label

@export var id: int

@export var money: int
@export var xp: int

var items: Dictionary

@export var item1_name: String
@export var item1_icon: Texture2D
@export var item2_name: String
@export var item2_icon: Texture2D
@export var item3_name: String
@export var item3_icon: Texture2D

var item1_amount: int
var item2_amount: int
var item3_amount: int

var item1_values: Array = [10, 15, 20]
var item2_values: Array = [25, 30, 35]
var item3_values: Array = [40, 45, 50]


func _ready() -> void:
	button.pressed.connect(_on_button_pressed)
	regenerate_task()


func _on_button_pressed() -> void:
	selected.emit(id, items, money, xp)


func regenerate_task() -> void:
	money_label.text = str(money)
	xp_label.text = str(xp)
	
	item1_amount = item1_values[randi_range(0, len(item1_values) - 1)]
	item2_amount = item2_values[randi_range(0, len(item2_values) - 1)]
	item3_amount = item3_values[randi_range(0, len(item3_values) - 1)]
	
	if items == null:
		items = {}
	items["item1"] = [item1_name, item1_amount, item1_icon]
	items["item2"] = [item2_name, item2_amount, item2_icon]
	items["item3"] = [item3_name, item3_amount, item3_icon]

	button.button_pressed = false
