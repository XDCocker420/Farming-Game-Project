extends CharacterBody2D

# Referenzen zu deinem NPC (CharacterBody2D) und dessen NavigationAgent2D
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var interaction_area: Area2D = $InteractArea
@onready var notification_anim:AnimatedSprite2D = $Notification
@onready var player:CharacterBody2D = %Player
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
		#player.follow_martha(true)
		#done_tut()
		to_farm()
	if argument == "done_tutorial":
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

		var spielbeschreibung:String = "You are an NPC in our farming game.
		Answer all questions as best you can with the knowledge provided. 
		If it's not possible, just say I'm sorry, I don't know that. 
		Generally, if a door opens, you can interact with it.
		About our game: Controls: W - Up, A - Left, S - Down, D - Right, Shift - Run faster, E - Interact with things, F - Leave farm fields, Esc - Game menu
		The buildings: Crop fields: Plants can be grown here. You get higher chances of more plants if you water the plants.
		You have to be quick here, as it only works in the first stage. With E you can switch between watering and harvesting.
		About the various production buildings: In the feed house, animal feed can be produced. The food looks like cooper-ore/is cooper ore and all animals have the same feed. If the users asks were it can produce cooper-ore you should say that thats the food so in the foodhouse. The food is cooper ore because our animals are the hoyl animals from appolo the greek god.
		In the weaving mill, wool can be processed further.
		In the dairy, milk products can be processed further. With E you can enter all production buildings except the feed house because this one has a ui. Inside the buildings are the various devices. If you interact with them via E, the corresponding UI opens.
		For the feed house, the UI opens directly outside in front of the building. Now about the animals: When you go to them, the door opens and when you are in the animal area, you can open the corresponding UI with E.
		There are then two options: Feed and the respective interaction of the animal, e.g., milking for cows, shearing for sheep. If you select one of the two and then hover over an animal, you see an outline indicating that you can perform the respective interaction with the cow.
		You can buy the beer (the goal of the game) for 100 000 in the pub in the center of the city/town.
		The market is located in the town on the main road close to the center. You can sell items for money. You can select an amount and a price. After some time the item will be bought and you get the money.
		The task caravan is located next to the market on the left. You can complete task, that means sell items for money and exp. If you click on one contract you will see the items that are need to complete this contract. on the bottom you'll find a button to complete this contract.
		The shop is located north from the town center. the building is the one with the supermarket on it. in this building you can buy the seed that are needed for planting the crops.
		NPCs are loacated all around the town/city. You can talk to them.
		If you buy seeds from the shop you also need to plant them on the farming fields.
		The production buildings should show what they need to produce there new products.
		That was all the info. Please answer ins Englisch. Now comes the question: "
		
		# Build the JSON payload.
		var payload = {
			"contents": [{
				"parts": [{"text": spielbeschreibung + Dialogic.VAR.inputs.custom_question + " The output should have a maximum of 50 words"}]
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
