extends Area2D


@onready var canvas_group: CanvasGroup = $CanvasGroup
@onready var ui_farming: PanelContainer = $CanvasLayer/ui_farming

var field_list: Array

var player_in_area: bool


func _ready() -> void:
	field_list = canvas_group.get_children()
	
	body_entered.connect(_on_player_entered)
	body_exited.connect(_on_player_exited)
	
	for field: Area2D in field_list:
		field.field_clicked.connect(_on_field_clicked)


func _on_field_clicked() -> void:
	pass
	
	
func _on_player_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_area = true
		ui_farming.show()
		

func _on_player_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_area = false
		ui_farming.hide()
