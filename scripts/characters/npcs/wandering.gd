extends State
class_name NPCWander

# Referenzen zu deinem NPC (CharacterBody2D) und dessen NavigationAgent2D
@export var npc: CharacterBody2D
@export var navigation_agent: NavigationAgent2D

# Wichtige Punkte (z.B. Marktplatz, Schmiede, etc.) – zur Laufzeit definierbar
@export var important_points: Array[Vector2] = [Vector2(500,400), Vector2(300,200)]
# Optionaler Home-Punkt, zu dem der NPC abends zurückkehrt
@export var home_point: Vector2

# Bewegungsgeschwindigkeit
@export var move_speed: float = 100.0
# Zeit, die der NPC an einem Zielpunkt verweilen soll
@export var wait_time: float = 2.0

# Intern: aktuelles Ziel
var current_target: Vector2
# Timer zum Warten nach Zielerreichen
var wait_timer: Timer

func _ready() -> void:
	# Erstelle dynamisch einen Timer, falls nicht bereits im Node vorhanden
	wait_timer = Timer.new()
	wait_timer.wait_time = wait_time
	wait_timer.one_shot = true
	add_child(wait_timer)
	wait_timer.connect("timeout", Callable(self, "_on_wait_timeout"))
	choose_new_target()

func enter() -> void:
	# Beim Zustandswechsel wird ein neues Ziel gewählt
	choose_new_target()

func exit() -> void:
	# Verbindung zum Timer wieder trennen, falls nötig
	if wait_timer.timeout.is_connected(_on_wait_timeout):
		wait_timer.timeout.disconnect(_on_wait_timeout)

func physics_update(delta: float) -> void:
	if not npc or not navigation_agent:
		return

	# Aktualisiere das Ziel des NavigationAgent2D, falls sich das Ziel geändert hat
	if navigation_agent.target_position != current_target:
		navigation_agent.target_position = current_target

	# Wenn das Ziel noch nicht erreicht ist, folge dem Pfad
	if not navigation_agent.is_target_reached():
		# Hole den nächsten Punkt auf dem berechneten Pfad
		var next_position = navigation_agent.get_next_path_position()
		var direction = (next_position - npc.position).normalized()
		# Setze die Geschwindigkeit des NPCs
		npc.velocity = direction * move_speed

		# Bestimme anhand der Geschwindigkeit die passende Animation
		if abs(npc.velocity.x) > abs(npc.velocity.y):
			if npc.velocity.x > 0:
				_play_animation("walk_right")
			else:
				_play_animation("walk_left")
		else:
			if npc.velocity.y > 0:
				_play_animation("walk_down")
			else:
				_play_animation("walk_up")
		npc.move_and_slide()
	else:
		# Ziel erreicht: NPC stoppt und wechselt in einen "idle"-Zustand
		npc.velocity = Vector2.ZERO
		_play_animation("idle_down")  # Alternativ: Letzte Blickrichtung verwenden
		# Starte den Timer, um nach einer kurzen Pause ein neues Ziel zu wählen
		if not wait_timer.is_stopped():
			wait_timer.start()

func _on_wait_timeout() -> void:
	choose_new_target()

func choose_new_target() -> void:
	# Beispielhafte Logik:
	# Falls es Nacht ist (hier könntest du deine Zeitlogik einbauen), wähle den Home-Punkt
	# Andernfalls: Wähle zufällig einen der wichtigen Orte
	# (Die Logik kann beliebig erweitert werden.)
	var is_night = false  # Hier müsstest du deine Tageszeitlogik einbinden
	if is_night and home_point:
		current_target = home_point
	else:
		if important_points.size() > 0:
			var index = randi() % important_points.size()
			current_target = important_points[index]
		else:
			# Fallback: Nicht bewegen
			current_target = npc.position
	
	# Aktualisiere den NavigationAgent2D
	if navigation_agent:
		navigation_agent.target_position = current_target
		
func process_input(_event: InputEvent):
	if _event.is_action_pressed("interact"):
		print("Test")
		transitioned.emit(self, "Talking")

func _play_animation(anim_name: String) -> void:
	# Annahme: Der NPC besitzt als Kind einen AnimatedSprite2D mit dem Namen "AnimatedSprite2D"
	var sprite = npc.get_node("AnimatedSprite2D")
	if sprite:
		sprite.play(anim_name)
