extends PanelContainer

@onready var btn:Button = $Button

func _ready() -> void:
	#btn.button_down.connect(_on_down)
	#btn.button_up.connect(_on_release)
	#btn.pressed.connect(_on_down)
	btn.toggled.connect(_on_toggle)
	
	#btn.button_group.pressed.connect(_on_release)
	
func _on_toggle(toggled_on:bool):
	if toggled_on:
		modulate = Color(0.8,0.8,0.8,1.0)
	else:
		modulate = Color(1.0,1.0,1.0,1.0)
	
func _on_down():
	print("adbadu")
	modulate = Color(0.8,0.8,0.8,1.0)
	
func _on_release():
	print("bbb")
	modulate = Color(1.0,1.0,1.0,1.0)
