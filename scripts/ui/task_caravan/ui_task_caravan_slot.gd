extends PanelContainer

@onready var btn:Button = $Button

func _ready() -> void:
	btn.button_down.connect(_on_down)
	btn.button_up.connect(_on_release)
	
	
func _on_down():
	print("adbadu")
	modulate = Color(0.8,0.8,0.8,1.0)
	
func _on_release():
	modulate = Color(1.0,1.0,1.0,1.0)
