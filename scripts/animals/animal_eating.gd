extends State
class_name  AnimalEating

var move_direction:Vector2
@export var animal:CharacterBody2D
@export var move_speed := 50.0
@onready var player:AnimatedSprite2D = $"../../AnimatedSprite2D"
@onready var timer = $Timer

signal eating_ended

var looking_direction = "down"
var once:bool = false
var direction:Vector2

func _ready() -> void:
	timer.wait_time = 2
	
func enter():
	if timer.timeout.get_connections().size() < 1:
		timer.timeout.connect(_on_timer_timeout)
	once = false
	direction = Vector2(0,0)
	
func exit():
	eating_ended.emit()
	if timer.timeout.get_connections().size() >= 1:
		timer.timeout.disconnect(_on_timer_timeout)
	
func physics_update(_delta:float):
	if animal:
		var ft_pos = get_parent().get_parent().get_parent().get_node("FeedingThrough").position
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
	
func _on_timer_timeout():
	transitioned.emit(self, "fed")
