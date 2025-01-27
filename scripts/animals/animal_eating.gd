extends State
class_name  AnimalEating

var move_direction:Vector2
@export var animal:CharacterBody2D
@export var move_speed := 2000
@onready var player:AnimatedSprite2D = $"../../AnimatedSprite2D"
@onready var timer = $Timer
@export var movement_target: Node2D
@onready var navigation_agent: NavigationAgent2D = $"../../NavigationAgent2D"
@onready var recalc_timer : Timer = $"../../RecalcTimer"

var on_nav_link : bool = false
var nav_link_end_position : Vector2

var rand_pos:Vector2
var looking_direction = "down"
var once:bool = false
var direction:Vector2

func _ready() -> void:
	movement_target = get_parent().get_parent().get_parent().get_node("FeedingThrough")
	recalc_timer.timeout.connect(_on_recalc_timer_timeout)
	navigation_agent.link_reached.connect(_on_navigation_link_reached)
	navigation_agent.waypoint_reached.connect(_on_waypoint_reached)
	navigation_agent.velocity_computed.connect(_on_velocity_computed)
	navigation_agent.path_desired_distance = 1.0
	navigation_agent.target_desired_distance = 1.0


	# On the first frame the NavigationServer map has not-
	# yet been synchronized; region data and any path query will return empty.
	# Wait for the NavigationServer synchronization by awaiting one frame in the script.
	# Make sure to not await during _ready.
	call_deferred("actor_setup")

	timer.wait_time = 2
	rand_pos = Vector2(randf_range(-20, 60),0)
	
func enter():
	if timer.timeout.get_connections().size() < 1:
		timer.timeout.connect(_on_timer_timeout)
	once = false
	direction = Vector2(0,0)
	
func exit():
	if timer.timeout.get_connections().size() >= 1:
		timer.timeout.disconnect(_on_timer_timeout)
	
func physics_update(_delta:float):
	if navigation_agent.is_navigation_finished():
		print("awdbadjbn")
		return

	# Get the next path point from the navigation agent.
	var current_agent_position: Vector2 = animal.position
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()

	# Calculate the velocity to move towards the next path point.
	var new_velocity = current_agent_position.direction_to(next_path_position).normalized() * move_speed * _delta
	if navigation_agent.avoidance_enabled:
		navigation_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)
	"""
	## TODO: Add pathfinding
	if animal:
		var ft_pos = get_parent().get_parent().get_parent().get_node("FeedingThrough").position + rand_pos
		direction = ft_pos - animal.position
	
		if direction.length() < 100:
			player.play("eating")
			if !once:
				get_parent().get_parent().get_parent().get_node("FeedingThrough").food_count -= 1
				once = true
				timer.wait_time = 2
				timer.start()
		else:
			animal.velocity = direction.normalized() * move_speed
			if animal.velocity.x > 0:
				looking_direction = "right"
			elif animal.velocity.x < 0:
				looking_direction = "left"
			elif animal.velocity.y > 0:
				looking_direction = "down"
			elif animal.velocity.y < 0:
				looking_direction = "up"
			animal.move_and_slide()
			player.play(looking_direction)
	"""
	
func _on_timer_timeout():
	transitioned.emit(self, "fed")
	
func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame
	set_target_position(movement_target.position)

## Set the target position of the navigation agent.
func set_target_position(target_position : Vector2 = Vector2.ZERO) -> void:
	navigation_agent.target_position = target_position

## Called when the recalculation timer times out.
func _on_recalc_timer_timeout() -> void:
	if not on_nav_link:
		set_target_position(movement_target.position)

## Called when a navigation link has been reached.
func _on_navigation_link_reached(details : Dictionary) -> void:
	on_nav_link = true # Temporarily disable recalculation to prevent jittering.
	nav_link_end_position = details.link_exit_position

## Called when a waypoint has been reached.
func _on_waypoint_reached(details : Dictionary) -> void:
	print("dwas")
	# This next line checks the distance to the waypoint with a threshhold.
	# If the distance is less than 5.0, then the waypoint has been reached.
	# This check produces unexpected results when comparing vectors directly.
	if details.position.distance_to(nav_link_end_position) < 5.0:
		on_nav_link = false

## Called when the navigation agent reports a new velocity.
func _on_velocity_computed(safe_velocity: Vector2):
	if animal:
		animal.velocity = safe_velocity
		animal.move_and_slide()
