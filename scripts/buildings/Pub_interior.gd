extends StaticBody2D

@onready var exit_area = $ExitArea
@onready var bar_area = $BarArea
@onready var buy_beer_ui = $CanvasLayer/buy_beer_ui

var in_exit_area: bool = false
var in_bar_area: bool = false

func _ready():
	exit_area.body_entered.connect(_on_exit_area_body_entered)
	exit_area.body_exited.connect(_on_exit_area_body_exited)
	
	bar_area.body_entered.connect(_on_bar_area_body_entered)
	bar_area.body_exited.connect(_on_bar_area_body_exited)
	
	# Verstecke das Beer UI beim Start
	if buy_beer_ui:
		buy_beer_ui.hide()
	else:
		# Try to find it by searching through children if @onready failed
		var found = false
		var potential_paths = ["buy_beer_ui", "CanvasLayer/buy_beer_ui", "UI/buy_beer_ui"]
		for path in potential_paths:
			var node = get_node_or_null(path)
			if node:
				buy_beer_ui = node
				buy_beer_ui.hide()
				found = true
				break
		# Optional: Add a warning if still not found, but no print for normal operation
		# if !found:
		# 	 push_warning("Could not find buy_beer_ui node in Pub_interior.")
		
	# Allow this node to receive unhandled inputs
	set_process_unhandled_input(true)

func _on_exit_area_body_entered(body):
	if body.is_in_group("Player"):
		in_exit_area = true
		if body.has_method("show_interaction_prompt"):
			body.show_interaction_prompt("Press E to exit interior")

func _on_exit_area_body_exited(body):
	if body.is_in_group("Player"):
		in_exit_area = false
		if body.has_method("hide_interaction_prompt"):
			body.hide_interaction_prompt()

func _on_bar_area_body_entered(body):
	if body.is_in_group("Player"):
		in_bar_area = true
		if body.has_method("show_interaction_prompt"):
			body.show_interaction_prompt("Press E to buy beer")

func _on_bar_area_body_exited(body):
	if body.is_in_group("Player"):
		in_bar_area = false
		if body.has_method("hide_interaction_prompt"):
			body.hide_interaction_prompt()
		
		# Hide UI when leaving area
		if buy_beer_ui:
			buy_beer_ui.hide()

func _unhandled_input(event):
	# Exit interior when pressing interact in exit area
	if event.is_action_pressed("interact") and in_exit_area:
		SceneSwitcher.transition_to_main.emit()
	
	# Toggle beer UI when pressing interact in bar area
	if event.is_action_pressed("interact") and in_bar_area:
		if buy_beer_ui:
			if buy_beer_ui.visible:
				buy_beer_ui.hide()
			else:
				buy_beer_ui.show()
	
	# Close UI when ESC is pressed
	if event.is_action_pressed("ui_cancel") and buy_beer_ui and buy_beer_ui.visible:
		buy_beer_ui.hide()
