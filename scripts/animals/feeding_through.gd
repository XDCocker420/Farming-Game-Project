extends Node2D

@onready var area:Area2D = $Area2D
@onready var animation:AnimatedSprite2D = $Area2D/AnimatedSprite2D
@onready var ui:Control = $UiFeedingThrough
@onready var spin_box:SpinBox = $UiFeedingThrough/Menu/SpinBox
@onready var submit:Button = $UiFeedingThrough/Menu/Submit
@onready var icon_box = $UiFeedingThrough/Menu/ui_cb_slot
@onready var icon:TextureRect = $UiFeedingThrough/Menu/ui_cb_slot/TextureButton/Background

var in_area:bool = false
var ui_is_open:bool = false
var is_full:bool = false
var food_name:String
var food_count:int


func _ready() -> void:
	area.body_entered.connect(on_body_enter)
	area.body_exited.connect(on_body_exit)
	submit.pressed.connect(on_submit)
	for i in get_parent().get_children():
		if i.is_in_group("Animal"):
			food_name = i.name.to_lower().rstrip("1234567890") + "_food"
			icon.texture = load("res://assets/gui/icons/" + food_name + ".png")
			icon.scale = Vector2(0.5,0.5)
			icon.position = Vector2(-3,-4)
			break
			
#func _process(delta: float) -> void:
#	if food_count == 0:
#		animation.play("empty")
	
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") && in_area:
		if !is_full:
			if ui_is_open:
				ui.hide()
				ui_is_open = false
			else:
				SaveGame.add_to_inventory(food_name, 2)
				var hungry_animals:Array = []
				for i in get_parent().get_children():
					if i.is_in_group("Animal"):
						var machine = i.get_node("State Machine")
						if machine.current_state is AnimalHungry:
							hungry_animals.append(i)
				spin_box.max_value = min(hungry_animals.size(),SaveGame.get_item_count(food_name))
				if spin_box.max_value == 0:
					submit.disabled = true
				else:
					submit.disabled = false
				ui.show()
				ui_is_open = true


func notify_animal(anz:int):
	if anz <= 0:
		return
	animation.play("full")
	var hungry_animals:Array = []
	for i in get_parent().get_children():
		if i.is_in_group("Animal"):
			var machine = i.get_node("State Machine")
			if machine.current_state is AnimalHungry:
				hungry_animals.append(i)
	if anz <= hungry_animals.size():
		for h in range(anz):
			var machine = hungry_animals[h].get_node("State Machine").current_state
			machine.transitioned.emit(machine, "Eat")
	else:
		food_count = anz - hungry_animals.size()
		for j in range(hungry_animals.size()):
			var machine = hungry_animals[j].get_node("State Machine").current_state
			machine.transitioned.emit(machine, "Eat")
			
			
func on_submit():
	if spin_box.value < 1:
		return
	## TODO: Let Spinbox not Submit when to big even on current value
	food_count = spin_box.value
	SaveGame.remove_from_inventory(food_name, food_count)
	notify_animal(food_count)
	ui_is_open = false
	ui.hide()
	
	
func on_body_enter(body:Node2D):
	if body.is_in_group("Player"):
		in_area = true
	
func on_body_exit(body:Node2D):
	if body.is_in_group("Animal") && food_count == 0:
		animation.play("empty")
	if body.is_in_group("Player"):
		in_area = false
		ui_is_open = false
