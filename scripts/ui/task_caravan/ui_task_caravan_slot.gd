extends PanelContainer


signal task_selected(id: int, item1: Array, item2: Array, item3: Array)

@onready var button: TextureButton = $TextureButton
@onready var money_label: Label = $VBoxContainer/HBoxContainer/money_label
@onready var xp_label: Label = $VBoxContainer/HBoxContainer2/xp_label

@export var id: int

# the higher the stage, the more resources 
# will be needed to complete the task
# but the more xp and money you get
@export var stage: int

var money: int
var xp: int

var item1_name: String
var item1_amount: int
var item2_name: String
var item2_amount: int
var item3_name: String
var item3_amount: int


func _ready() -> void:
	button.pressed.connect(_on_button_pressed)
	generate_task()
	update_visual()


func _on_button_pressed() -> void:
	task_selected.emit(id, [item1_name, item1_amount], [item2_name, item2_amount], [item3_name, item3_amount])


func generate_task() -> void:
	if stage == 0:
		money = randi_range(10, 50)
		xp = [50, 60, 70, 80, 90, 100][randi_range(0, 5)]
		item1_name = ["wheat", "carrot", "corn", "potatoe"][randi_range(0, 3)]
		item1_amount = randi_range(10, 30)
	elif stage == 1:
		money = randi_range(200, 500)
		xp = [100, 150, 200, 250, 300][randi_range(0, 4)]
		item1_name = ["wheat", "carrot", "corn", "potatoe"][randi_range(0, 3)]
		item1_amount = randi_range(25, 50)
		item2_name = ["wheat", "carrot", "corn", "potatoe"][randi_range(0, 3)]
		item2_amount = randi_range(25, 50)
	elif stage == 2:
		money = randi_range(500, 1000)
		xp = [500, 600, 700, 800, 900, 1000][randi_range(0, 5)]
		item1_name = ["wheat", "carrot", "corn", "potatoe"][randi_range(0, 3)]
		item1_amount = randi_range(50, 100)
		item2_name = ["wheat", "carrot", "corn", "potatoe"][randi_range(0, 3)]
		item2_amount = randi_range(50, 100)
		item3_name = ["wheat", "carrot", "corn", "potatoe"][randi_range(0, 3)]
		item3_amount = randi_range(50, 100)


func update_visual() -> void:
	money_label.text = str(money)
	xp_label.text = str(xp)
