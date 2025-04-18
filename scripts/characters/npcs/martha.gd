extends CharacterBody2D

# Referenzen zu deinem NPC (CharacterBody2D) und dessen NavigationAgent2D
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var interaction_area: Area2D = $InteractArea
@onready var notification_anim:AnimatedSprite2D = $Notification
@onready var player:CharacterBody2D = %CutPlayer
@onready var http_request:HTTPRequest = $HTTPRequest

# Bewegungsgeschwindigkeit
@export var move_speed: float = 50.0

@export var scheune:StaticBody2D

# Intern: aktuelles Ziel
var current_target: Vector2

var history:Array[Vector2]

var player_in_area:bool = false

var save_dialog_pos:Vector2

var go_to_player:bool = false

var go_to_scheune:bool = false

var go_to_tutorial:bool = false

var go_to_farm:bool = false

var once1:bool = false
var once2:bool = false
var once3:bool = false
var once4:bool = false

var walk_pos:Vector2
var go_to_walk:bool = false

func _ready() -> void:
	navigation_agent.velocity_computed.connect(Callable(_on_velocity_computed))
	
	interaction_area.body_entered.connect(_on_area_entered)

	interaction_area.body_exited.connect(_on_area_exited)

	Dialogic.signal_event.connect(_on_dialogic_signal)

func _on_dialogic_signal(argument:String):
	if argument == "start_moving":
		to_farm()
	if argument == "done_tutorial":
		print("transition to main scene")
		SceneSwitcher.transition_to_new_scene.emit("game_map", player.global_position)
	if argument == "show_farming":
		current_target = global_position - Vector2(0, 20)
		player.follow_martha(false)
		player.walk_to(Vector2(-186,-186))
		#to_scheune()
	if argument == "scheune_end":
		go_to_scheune = false
		done_tut()
	if argument == "trigger_ai":
		
		# Define your API key and URL.
		var api_key = ConfigReader.get_api_key()
		var url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=" + api_key

		# Set up the headers.
		var headers = ["Content-Type: application/json"]

		# Build the JSON payload.
		var payload = {
			"contents": [{
				"parts": [{"text": Dialogic.VAR.inputs.custom_question + "Die Ausgabe soll maximal 30 Wörter haben"}]
			}]
		}
		
		# Convert the dictionary to a JSON string.
		var json_payload = JSON.stringify(payload)

		# Send the POST request.
		var error = http_request.request(url, headers, HTTPClient.METHOD_POST, json_payload)
		if error != OK:
			print("Error sending request: ", error)
			
		
		http_request.request_completed.connect(_on_request_completed)


func _physics_process(_delta: float) -> void:	
	if not navigation_agent:
		return
		
	if not Dialogic.VAR.inputs.should_move:
		global_position = save_dialog_pos

	if navigation_agent.is_target_reached():
		
		if go_to_player && !once1:
			once1 = true
			#notification_anim.hide()
			var file_path:String = "res://dialogs/timelines/tutorial/tutorial_first_meet.dtl"
		
			var timeline:DialogicTimeline = load(file_path)
			timeline.process()
			
			Dialogic.start(timeline)
				
		if go_to_scheune && !once2:
			once2 = true
			
			var file_path:String = "res://dialogs/timelines/tutorial/scheune.dtl"
		
			var timeline:DialogicTimeline = load(file_path)
			timeline.process()
			
			Dialogic.start(timeline)
			
		if go_to_tutorial && !once3:
			once3 = true
			
			var file_path:String = "res://dialogs/timelines/tutorial/end_tutorial.dtl"
		
			var timeline:DialogicTimeline = load(file_path)
			timeline.process()
			
			Dialogic.start(timeline)
			
		if go_to_farm && !once4:
			once4 = true
			var file_path:String = "res://dialogs/timelines/tutorial/farm_felder.dtl"
			
			var timeline:DialogicTimeline = load(file_path)
			timeline.process()
			
			Dialogic.start("res://dialogs/timelines/tutorial/farm_felder.dtl")



	if navigation_agent.target_position != current_target:
		navigation_agent.target_position = current_target
		
	if NavigationServer2D.map_get_iteration_id(navigation_agent.get_navigation_map()) == 0:
		return

	if not navigation_agent.is_target_reached() && Dialogic.VAR.inputs.should_move:
		var next_position = navigation_agent.get_next_path_position()

		var new_velocity: Vector2 = global_position.direction_to(next_position) * move_speed

		if navigation_agent.avoidance_enabled:
			navigation_agent.set_velocity(new_velocity)
		else:
			_on_velocity_computed(new_velocity)

		if abs(velocity.x) > abs(velocity.y):
			if velocity.x > 0:
				_play_animation("right")
			else:
				_play_animation("left")
		else:
			if velocity.y > 0:
				_play_animation("down")
			else:
				_play_animation("up")

	else:
		velocity = Vector2.ZERO
		_play_animation("idle")


func _on_velocity_computed(safe_velocity: Vector2):
	velocity = safe_velocity
	move_and_slide()

		
func addToHistory(item):
	history.push_back(item)
	while history.size() > 2:
		history.pop_front()

func _input(_event: InputEvent):
	if _event.is_action_pressed("interact") && player_in_area && Dialogic.current_timeline == null:
		Dialogic.VAR.inputs.should_move = false
		save_dialog_pos = global_position

		var file_path:String = "res://dialogs/timelines/" + name.to_lower() + ".dtl"
		
		var timeline:DialogicTimeline = load(file_path)
		timeline.process()
		
		Dialogic.start(timeline)


func _play_animation(anim_name: String) -> void:
	var sprite = get_node("AnimatedSprite2D")
	if sprite:
		sprite.play(anim_name)
		
func _on_area_entered(body:Node2D):
	if body.is_in_group("Player"):
		player_in_area = true
	
func _on_area_exited(body:Node2D):
	if body.is_in_group("Player"):
		player_in_area = false
	
func to_player():
	notification_anim.show()
	await get_tree().create_timer(0.5).timeout
	notification_anim.hide()
	go_to_player = true
	current_target = player.global_position + Vector2(5,-15)
	
func to_scheune():
	go_to_player = false
	current_target = scheune.global_position
	await get_tree().create_timer(1.0).timeout
	go_to_scheune = true
	
func show_notification():
	notification_anim.visible = true
	
func done_tut():
	go_to_scheune = false
	current_target = Vector2(-41, 77)
	await get_tree().create_timer(1.0).timeout
	go_to_tutorial = true
	
func to_farm():
	go_to_player = false
	player.follow_martha(true)
	current_target = Vector2(-249, -189)
	await get_tree().create_timer(1.0).timeout
	go_to_farm = true
	
# This function is called when the request is completed.
func _on_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var json = JSON.new()
		json.parse(body.get_string_from_utf8())
		var response = json.get_data()
		var data = response.candidates[0].content.parts[0].text
		Dialogic.VAR.inputs.custom_answer = data
