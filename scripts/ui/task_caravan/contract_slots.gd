extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.focus_entered.connect(_on_enter_test)

func _on_enter_test():
	pass
