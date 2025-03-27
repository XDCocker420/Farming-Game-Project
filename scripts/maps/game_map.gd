extends Node2D

# This script should be attached to the "Game" node in the game_map.tscn scene

# Wir verwenden eine Methode, die den Spieler sicher findet, unabhängig vom Pfad
var player = null
var position_retry_count = 0
var position_retry_timer = null

func _ready():
	# Add the Game node to a group so it can be found from other scripts
	add_to_group("game_map")
	
	print("=== GAME MAP LOADED ===")
	
	# Finde den Spieler, unabhängig vom Pfad
	player = _find_player()
	print("Player node path: ", player.get_path() if player else "Player not found")
	
	# Erstelle einen Timer für wiederholtes Positionieren
	position_retry_timer = Timer.new()
	position_retry_timer.wait_time = 0.1  # 100ms
	position_retry_timer.one_shot = false
	position_retry_timer.timeout.connect(_on_position_retry_timer)
	add_child(position_retry_timer)
	
	# Warte einen Frame, um sicherzustellen, dass die Szene vollständig geladen ist
	await get_tree().process_frame
	
	# Position the player based on where they came from
	if SaveGame.last_exterior_position != Vector2.ZERO and player:
		# If we have a saved position (coming from a building), use it
		print("Repositioning player to saved exterior position:")
		print("- Current position: ", player.global_position)
		print("- Saved position: ", SaveGame.last_exterior_position)
		
		# Verwende die neue Methode, wenn verfügbar
		if player.has_method("set_position_from_exterior"):
			player.set_position_from_exterior(SaveGame.last_exterior_position)
		else:
			# Fallback: Setze die Position direkt
			player.global_position = SaveGame.last_exterior_position
			player.position = SaveGame.last_exterior_position
		
		# Debug: Überprüfe die tatsächliche Position des Spielers nach dem Setzen
		print("- Actual global position after setting: ", player.global_position)
		print("- Actual local position after setting: ", player.position)
		
		# Debug: Zeige an, welches Gebäude verlassen wurde
		var building_names = ["Unbekannt", "Futterhaus", "Weberei", "Molkerei"]
		var building_name = "Unbekannt"
		if SaveGame.last_building_entered >= 0 and SaveGame.last_building_entered < building_names.size():
			building_name = building_names[SaveGame.last_building_entered]
		print("Spieler hat das Gebäude verlassen: " + building_name)
		
		# Deferred Positionierung versuchen, falls die sofortige nicht wirkt
		call_deferred("_ensure_player_position", SaveGame.last_exterior_position)
		
		# Start the retry timer as a last resort
		position_retry_count = 0
		position_retry_timer.start()
	else:
		if !player:
			print("ERROR: Player node not found!")
		else:
			print("No exterior position saved, using default position")

func _on_position_retry_timer():
	position_retry_count += 1
	
	# Finde den Spieler erneut, falls er beim ersten Mal nicht gefunden wurde
	if player == null:
		player = _find_player()
		if player == null:
			print("Still can't find player on retry #", position_retry_count)
			# Nach 10 Versuchen aufgeben
			if position_retry_count >= 10:
				position_retry_timer.stop()
			return
	
	# Prüfe, ob die Position gesetzt werden muss
	if SaveGame.last_exterior_position != Vector2.ZERO:
		var current_pos = player.global_position
		
		# Wenn die Position nahe (0,0) ist oder weit von der gespeicherten Position entfernt ist
		if current_pos.length() < 1.0 or current_pos.distance_to(SaveGame.last_exterior_position) > 10.0:
			print("Retry #", position_retry_count, ": Re-positioning player")
			if player.has_method("set_position_from_exterior"):
				player.set_position_from_exterior(SaveGame.last_exterior_position)
			else:
				player.global_position = SaveGame.last_exterior_position
			print("New position: ", player.global_position)
		else:
			print("Position seems correct now, stopping retry timer")
			position_retry_timer.stop()
	
	# Nach 10 Versuchen aufgeben
	if position_retry_count >= 10:
		position_retry_timer.stop()

# Durchsucht den Szenenbaum nach dem Spieler-Node
func _find_player():
	# Methode 1: Direkter Pfad
	var direct_player = get_node_or_null("Map/Player")
	if direct_player and direct_player.is_in_group("Player"):
		print("Found player via direct path: Map/Player")
		return direct_player
		
	# Methode 2: Suche unter Map, falls vorhanden
	var map_node = get_node_or_null("Map")
	if map_node:
		for child in map_node.get_children():
			if child.is_in_group("Player"):
				print("Found player as child of Map: ", child.name)
				return child
	
	# Methode 3: Unique Name
	var unique_player = get_node_or_null("%Player")
	if unique_player:
		print("Found player via unique name: %Player")
		return unique_player
		
	# Methode 4: Gruppe
	var players_in_group = get_tree().get_nodes_in_group("Player")
	if players_in_group.size() > 0:
		print("Found player via group lookup")
		return players_in_group[0]
	
	# Methode 5: Rekursive Suche im Szenenbaum
	var root = get_tree().root
	var player_node = _find_player_recursive(root)
	if player_node:
		print("Found player via recursive search: ", player_node.name)
		return player_node
		
	print("ERROR: Could not find player node by any method")
	return null
	
# Rekursive Suche nach dem Spieler-Node
func _find_player_recursive(node):
	if node.is_in_group("Player"):
		return node
		
	for child in node.get_children():
		var found = _find_player_recursive(child)
		if found:
			return found
			
	return null

# Eine zusätzliche Methode, um die Spielerposition im nächsten Frame erneut zu setzen
func _ensure_player_position(pos: Vector2):
	print("Deferred player positioning to: ", pos)
	if player:
		if player.has_method("set_position_from_exterior"):
			player.set_position_from_exterior(pos)
		else:
			player.global_position = pos
		# Überprüfen, ob die Position korrekt gesetzt wurde
		print("Final player position check: ", player.global_position) 