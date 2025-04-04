extends State
class_name  AnimalFed

var position:Vector2
var move_direction:Vector2
var wander_time:float
@export var animal:CharacterBody2D
@export var move_speed := 25.0
@onready var timer = $Timer
@onready var player:AnimatedSprite2D = $"../../AnimatedSprite2D"


var points:Array[Vector2] = [
	Vector2(-194,-136),
	Vector2(-3,-193),
	Vector2(79, -162),
	Vector2(244, -111),
	Vector2(211, -2),
	Vector2(-7, 20),
	Vector2(-226, -6)
]

var cop_points:Array[Vector2]


var looking_direction = "down"

func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)
	timer.wait_time = ConfigReader.get_time(_translate(animal.name.to_lower().rstrip("1234567890")))
	
func _translate(name:String):
	match name:
		"cow":
			return "milk"
		"chicken":
			return "egg"
		"sheep":
			return "white_wool"
		"pig":
			return "meat"

func enter():
	match $"../..".looking_direction:
		1:
			player.play("down")
		2:
			player.play("up")
		3:
			player.play("left")
		4:
			player.play("right")
	
	timer.start()
		
#func physics_update(_delta:float):
	#if animal:
		#move_direction = position - animal.position
		#animal.velocity = move_direction.normalized() * move_speed
		#if move_direction.x > 0:
			#looking_direction = "right"
		#elif move_direction.x < 0:
			#looking_direction = "left"
		#elif move_direction.y > 0:
			#looking_direction = "down"
		#elif move_direction.y < 0:
			#looking_direction = "up"
		#animal.move_and_slide()
		#player.play(looking_direction)
		

func _on_timer_timeout():
	transitioned.emit(self, "full")
