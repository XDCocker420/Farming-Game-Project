extends CanvasLayer

signal transitioned

@onready var anim_player:AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	anim_player.animation_finished.connect(_on_animation_finished)

func transition():
	anim_player.play("fade_to_black")

func _on_animation_finished(anim_name):
	if anim_name == "fade_to_black":
		transitioned.emit()
		anim_player.play("fade_to_normal")
