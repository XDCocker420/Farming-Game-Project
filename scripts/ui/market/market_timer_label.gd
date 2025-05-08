extends Label

# Timer-Label für Markt-Slots zur Anzeige der verbleibenden Verkaufszeit

@onready var parent_slot = get_parent()

func _ready():
	# Initialisierung
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Stileinstellungen
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	# Timer für regelmäßige Aktualisierung
	var update_timer = Timer.new()
	update_timer.wait_time = 0.5  # Häufigere Updates (alle 0.5 Sekunden)
	update_timer.autostart = true
	update_timer.timeout.connect(_update_time_display)
	add_child(update_timer)
	
	# Verbinde mit dem market_item_sold Signal
	SaveGame.market_item_sold.connect(_on_market_item_sold)
	
	# Aktualisiere initial
	_update_time_display()

func _update_time_display():
	# Wenn kein Parent-Slot vorhanden ist, ausblenden
	if !parent_slot:
		visible = false
		return
	
	# Überprüfe, ob der Slot ein Item hat
	if parent_slot.get("item_name") == "" or parent_slot.get("item_name") == null:
		visible = false
		return
	
	# Slot-ID ermitteln
	var slot_id = -1
	if parent_slot.get("id") != null:
		slot_id = parent_slot.get("id")
	else:
		visible = false
		return
	
	# Entsprechendes Markt-Item suchen
	var market_item = SaveGame.get_market_by_id(slot_id)
	if !market_item or market_item.end_time_ms <= 0:
		visible = false
		return
	
	# Berechne verbleibende Zeit
	var current_time = Time.get_ticks_msec()
	var remaining_ms = market_item.end_time_ms - current_time
	
	if remaining_ms <= 0:
		visible = false
		# Versuche, den Slot zu leeren, falls der Verkaufsprozess nicht korrekt funktioniert hat
		if parent_slot.has_method("clear"):
			parent_slot.clear()
		return
	
	# Anzeige formatieren
	var remaining_seconds = int(remaining_ms / 1000)
	var hours = remaining_seconds / 3600
	var minutes = (remaining_seconds % 3600) / 60
	var seconds = remaining_seconds % 60
	
	if hours > 0:
		text = "%d:%02d:%02d" % [hours, minutes, seconds]
	else:
		text = "%02d:%02d" % [minutes, seconds]
	
	# Farbe je nach verbleibender Zeit anpassen
	if remaining_seconds < 30:
		modulate = Color(1, 0, 0) # Rot für kritische Zeit
	elif remaining_seconds < 60:
		modulate = Color(1, 0.5, 0) # Orange für wenig Zeit
	else:
		modulate = Color(1, 1, 1) # Standard-Weiß
	
	visible = true
	
# Wenn ein Item verkauft wurde, überprüfe, ob es dieses Slot betrifft
func _on_market_item_sold(item_name, count, total_price):
	if parent_slot and parent_slot.get("item_name") == item_name:
		visible = false
		# Sicherstellen, dass der Slot geleert wird
		if parent_slot.has_method("clear"):
			parent_slot.clear() 