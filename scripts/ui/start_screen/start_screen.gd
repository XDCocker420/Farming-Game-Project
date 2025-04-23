extends CanvasLayer

@onready var start_button: TextureButton = $StartButton
@onready var new_game_button:TextureButton = $NewGameButton

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	new_game_button.pressed.connect(_on_new_pressed)
	
func _on_start_pressed():
	if Dialogic.VAR.global.done_tutorial:
		SceneSwitcher.transition_to_main.emit()
	else:
		SceneSwitcher.transition_to_new_scene.emit("intro", Vector2.ZERO)
	
func _on_new_pressed():
	SaveGame.create_new_game()
	SceneSwitcher.transition_to_new_scene.emit("intro", Vector2.ZERO)
