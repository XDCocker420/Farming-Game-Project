extends CharacterBody2D

# Referenzen zu deinem NPC (CharacterBody2D) und dessen NavigationAgent2D
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var interaction_area: Area2D = $InteractArea
@onready var http_request:HTTPRequest = $HTTPRequest

# Wichtige Punkte (z.B. Marktplatz, Schmiede, etc.) – zur Laufzeit definierbar
@export var important_points: Array[Vector2] = [Vector2(91, 66), Vector2(-23, 43), Vector2(57,150)]
# Optionaler Home-Punkt, zu dem der NPC abends zurückkehrt
@export var home_point: Vector2

@export var market:StaticBody2D

# Bewegungsgeschwindigkeit
@export var move_speed: float = 25.0
# Zeit, die der NPC an einem Zielpunkt verweilen soll
@export var wait_time: float = 20.0

# Intern: aktuelles Ziel
var current_target: Vector2

var history:Array[Vector2]
# Timer zum Warten nach Zielerreichen
@export var wait_timer: Timer

var player_in_area:bool = false

var is_night:bool = false

@export var day_and_night:CanvasModulate

@export var items_to_buy:Array[String]

var go_to_market:bool = false

var save_dialog_pos:Vector2

func _ready() -> void:
	#wait_timer.timeout.connect(_on_wait_timeout)
	
	SaveGame.items_added_to_market.connect(_added_to_market)
	
	#DayDayCyle.is_night.connect(_on_is_night)
	#day_and_night.is_night.connect(_on_is_night)
	
	Dialogic.signal_event.connect(_on_dialogic_signal)
	
	navigation_agent.velocity_computed.connect(Callable(_on_velocity_computed))
	
	interaction_area.body_entered.connect(_on_area_entered)

	interaction_area.body_exited.connect(_on_area_exited)
	
	#choose_new_target()
	
"""
func _physics_process(delta: float) -> void:
	if  not navigation_agent:
		return
		
	if not Dialogic.VAR.inputs.should_move:
		global_position = save_dialog_pos

	if navigation_agent.is_target_reached():
		if go_to_market:
			## TODO: Implement buying from the market
			print("kaufen")
			# SaveGame.remove_market_item(items_to_buy[ irgendwas halt ])
			pass
				
		elif wait_timer.is_stopped():
			wait_timer.start(2)

	if navigation_agent.target_position != current_target:
		navigation_agent.target_position = current_target
		
	if NavigationServer2D.map_get_iteration_id(navigation_agent.get_navigation_map()) == 0:
		return

	if not navigation_agent.is_target_reached() && Dialogic.VAR.inputs.should_move:
		
		var next_position = navigation_agent.get_next_path_position()
		var direction = (next_position - position).normalized()
		# Setze die Geschwindigkeit des NPCs
		#var new_velocity = direction * move_speed
		var new_velocity: Vector2 = global_position.direction_to(next_position) * move_speed
		#velocity = direction * move_speed
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
		#move_and_slide()
	else:
		velocity = Vector2.ZERO
		_play_animation("idle")
"""
func _on_velocity_computed(safe_velocity: Vector2):
	velocity = safe_velocity
	move_and_slide()

func _on_wait_timeout() -> void:
	choose_new_target()

func choose_new_target() -> void:
	if is_night and home_point:
		current_target = home_point
	else:
		if important_points.size() > 0:
			var index = randi() % important_points.size()
			current_target = important_points[index]
			
			if current_target in history:
				choose_new_target()
			else:
				addToHistory(current_target)
		else:
			print("Please specify Important Points")
			current_target = position

	if navigation_agent:
		navigation_agent.target_position = current_target
		
func addToHistory(item):
	history.push_back(item)
	while history.size() > 2:
		history.pop_front()

func _input(_event: InputEvent):
	if _event.is_action_pressed("interact") && player_in_area && is_night && Dialogic.current_timeline == null:
		Dialogic.VAR.inputs.should_move = false
		save_dialog_pos = global_position

		var file_path:String = "res://dialogs/timelines/" + name.to_lower() + "_night.dtl"
		
		var timeline:DialogicTimeline = load(file_path)
		timeline.process()
		
		Dialogic.start(timeline)
		
	elif _event.is_action_pressed("interact") && player_in_area && Dialogic.current_timeline == null:
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

func _added_to_market(item_name:String):
	if item_name in items_to_buy:
		go_to_market = true
		current_target = market.global_position
	
func _on_is_night():
	is_night = true
	
# This function is called when the request is completed.
func _on_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var json = JSON.new()
		json.parse(body.get_string_from_utf8())
		var response = json.get_data()
		var data = response.candidates[0].content.parts[0].text
		print(data)
		Dialogic.VAR.inputs.custom_answer = data
		
		
func _on_dialogic_signal(argument:String):
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
		About the various production buildings: In the feed house, animal feed can be produced. In the weaving mill, wool can be processed further.
		In the dairy, milk products can be processed further. With E you can enter all production buildings except the feed house because this one has a ui. Inside the buildings are the various devices. If you interact with them via E, the corresponding UI opens.
		For the feed house, the UI opens directly outside in front of the building. Now about the animals: When you go to them, the door opens and when you are in the animal area, you can open the corresponding UI with E.
		There are then two options: Feed and the respective interaction of the animal, e.g., milking for cows, shearing for sheep. If you select one of the two and then hover over an animal, you see an outline indicating that you can perform the respective interaction with the cow.
		You can buy the beer (the goal of the game) for 100 000 in the pub in the center of the city/town.
		The market is located in the town on the main road close to the center. You can sell items for money. You can select an amount and a price. After some time the item will be bought and you get the money.
		The task caravan is located next to the market on the left. You can complete task, that means sell items for money and exp. If you click on one contract you will see the items that are need to complete this contract. on the bottom you'll find a button to complete this contract.
		The shop is located north from the town center. the building is the one with the supermarket on it. in this building you can buy the seed that are needed for planting the crops.
		NPCs are loacated all around the town/city. You can talk to them.
		Every animal has the same food. It looks like cooper-ore because our animals are the hoyl animals from appolo the greek god.
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
