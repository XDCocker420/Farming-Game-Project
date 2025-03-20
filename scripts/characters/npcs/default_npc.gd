extends CharacterBody2D

# Referenzen zu deinem NPC (CharacterBody2D) und dessen NavigationAgent2D
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var interaction_area: Area2D = $InteractArea

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

func _ready() -> void:
	wait_timer.timeout.connect(_on_wait_timeout)
	
	SaveGame.items_added_to_market.connect(_added_to_market)
	
	#DayDayCyle.is_night.connect(_on_is_night)
	#day_and_night.is_night.connect(_on_is_night)
	
	navigation_agent.velocity_computed.connect(Callable(_on_velocity_computed))
	
	interaction_area.body_entered.connect(_on_area_entered)

	interaction_area.body_exited.connect(_on_area_exited)
		
	choose_new_target()
	

func _physics_process(delta: float) -> void:
	if  not navigation_agent:
		return

	if navigation_agent.is_target_reached():
		if go_to_market:
			## TODO: Implement buying from the market
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
	if is_night && Dialogic.current_timeline == null:
		Dialogic.VAR.inputs.should_move = false

		var file_path:String = "res://dialogs/timelines/" + name.to_lower() + "_night.dtl"
		
		var timeline:DialogicTimeline = load(file_path)
		timeline.process()
		
		Dialogic.start(timeline)
		
	elif _event.is_action_pressed("interact") && player_in_area && Dialogic.current_timeline == null:
		Dialogic.VAR.inputs.should_move = false

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
		current_target = market.position
	
func _on_is_night():
	is_night = true
