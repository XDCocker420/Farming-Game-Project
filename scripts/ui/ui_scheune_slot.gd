extends PanelContainer

var display_names = {
	"cauliflower": "Cauli",
	"aubergine": "Eggplant"
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass


func _on_icon_mouse_entered() -> void:
	var name_label = $Node2D/name
	var icon_name = $Icon.texture.get_path().get_file().get_basename()

	if icon_name in display_names:
		name_label.text = display_names[icon_name]
	else:
		icon_name = icon_name[0].to_upper() + icon_name.substr(1,-1)
		name_label.text = icon_name
	name_label.show()


func _on_icon_mouse_exited() -> void:
	$Node2D/name.hide()
