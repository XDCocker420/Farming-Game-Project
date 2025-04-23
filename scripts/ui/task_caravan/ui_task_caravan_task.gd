extends PanelContainer


signal task_done

@onready var button: Button = $VBoxContainer2/MarginContainer3/PanelContainer/Button


func _ready() -> void:
	button.pressed.connect(_on_task_done_pressed)


func _on_task_done_pressed() -> void:
	if check():
		task_done.emit()


func check() -> bool:
	return false
