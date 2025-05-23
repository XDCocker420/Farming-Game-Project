extends Node2D

# This script should be attached to the "Game" node in the game_map.tscn scene

# Wir verwenden eine Methode, die den Spieler sicher findet, unabhängig vom Pfad
var player = null
var position_retry_count = 0
var position_retry_timer = null

func _ready():
	# Add the Game node to a group so it can be found from other scripts
	add_to_group("game_map")
	
	# Finde den Spieler, unabhängig vom Pfad
	player = _find_player()
	
	# Set up automatic z-indexes for objects in the scene
	_setup_z_indexes()
	
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
		
		# Verwende die neue Methode, wenn verfügbar
		if player.has_method("set_position_from_exterior"):
			player.set_position_from_exterior(SaveGame.last_exterior_position)
		else:
			# Fallback: Setze die Position direkt
			player.global_position = SaveGame.last_exterior_position
			player.position = SaveGame.last_exterior_position
		
		# Deferred Positionierung versuchen, falls die sofortige nicht wirkt
		call_deferred("_ensure_player_position", SaveGame.last_exterior_position)
		
		# Start the retry timer as a last resort
		position_retry_count = 0
		position_retry_timer.start()

# Set up automatic z-indexes for all dynamic objects in the scene
func _setup_z_indexes():
	# Use the ZIndexManager helper to manage z-indexes for each group
	var groups = ["buildings", "npcs", "crops", "animals"]
	for group in groups:
		var nodes = get_tree().get_nodes_in_group(group)
		ZIndexManager.add_z_index_management(nodes)

func _on_position_retry_timer():
	position_retry_count += 1
	
	# Finde den Spieler erneut, falls er beim ersten Mal nicht gefunden wurde
	if player == null:
		player = _find_player()
		if player == null:
			# Nach 10 Versuchen aufgeben
			if position_retry_count >= 10:
				position_retry_timer.stop()
			return
	
	# Prüfe, ob die Position gesetzt werden muss
	if SaveGame.last_exterior_position != Vector2.ZERO:
		var current_pos = player.global_position
		
		# Wenn die Position nahe (0,0) ist oder weit von der gespeicherten Position entfernt ist
		if current_pos.length() < 1.0 or current_pos.distance_to(SaveGame.last_exterior_position) > 10.0:
			if player.has_method("set_position_from_exterior"):
				player.set_position_from_exterior(SaveGame.last_exterior_position)
			else:
				player.global_position = SaveGame.last_exterior_position
		else:
			position_retry_timer.stop()
	
	# Nach 10 Versuchen aufgeben
	if position_retry_count >= 10:
		position_retry_timer.stop()

# Durchsucht den Szenenbaum nach dem Spieler-Node
func _find_player():
	# Methode 1: Direkter Pfad
	var direct_player = get_node_or_null("Map/Player")
	if direct_player and direct_player.is_in_group("Player"):
		return direct_player
		
	# Methode 2: Suche unter Map, falls vorhanden
	var map_node = get_node_or_null("Map")
	if map_node:
		for child in map_node.get_children():
			if child.is_in_group("Player"):
				return child
	
	# Methode 3: Unique Name
	var unique_player = get_node_or_null("%Player")
	if unique_player:
		return unique_player
		
	# Methode 4: Gruppe
	var players_in_group = get_tree().get_nodes_in_group("Player")
	if players_in_group.size() > 0:
		return players_in_group[0]
	
	# Methode 5: Rekursive Suche im Szenenbaum
	var root = get_tree().root
	var player_node = _find_player_recursive(root)
	if player_node:
		return player_node
		
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
	if player:
		if player.has_method("set_position_from_exterior"):
			player.set_position_from_exterior(pos)
		else:
			player.global_position = pos 