extends PanelContainer

@onready var feed:Button = $MarginContainer/HBoxContainer/Feed
@onready var collect:Button = $MarginContainer/HBoxContainer/Collect

signal feeding_state
signal collecting_state

func _ready() -> void:
	feed.pressed.connect(_feed_pressed)
	collect.pressed.connect(_collect_pressed)
	
func _feed_pressed():
	feeding_state.emit()
	
func _collect_pressed():
	collecting_state.emit()
