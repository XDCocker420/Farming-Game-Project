extends PanelContainer


# Signal now emits the ID of the completed task
signal task_done(task_id: int)

@onready var button: Button = $VBoxContainer2/MarginContainer3/PanelContainer/Button

# Store current task details
var current_task_id: int = -1
var current_items_req: Dictionary = {}
var current_money_reward: int = 0
var current_xp_reward: int = 0


func _ready() -> void:
	button.pressed.connect(_on_task_done_pressed)
	# Disable button initially until a task is loaded
	button.disabled = true


# New function to receive task details from the main UI
func set_current_task(task_id: int, items: Dictionary, money: int, xp: int) -> void:
	current_task_id = task_id
	current_items_req = items
	current_money_reward = money
	current_xp_reward = xp
	# Enable the button now that we have task data
	button.disabled = false


func _on_task_done_pressed() -> void:
	# Only proceed if a valid task is loaded
	if current_task_id == -1:
		return
		
	if check():
		# Remove items from inventory
		for item_key in current_items_req.keys():
			var item_data: Array = current_items_req[item_key]
			var item_name: String = item_data[0]
			var required_amount: int = item_data[1]
			
			if item_name != "" and required_amount > 0:
				SaveGame.remove_from_inventory(item_name, required_amount)
		
		# Grant rewards
		SaveGame.add_money(current_money_reward)
		LevelingHandler.add_experience_points(current_xp_reward) # Correct function name
		
		# Emit signal with the completed task ID
		task_done.emit(current_task_id)
		
		# Reset state and disable button after completion
		reset_state()


# Checks if player inventory meets the requirements
func check() -> bool:
	# If no task is loaded, requirements cannot be met
	if current_task_id == -1:
		return false
		
	for item_key in current_items_req.keys():
		var item_data: Array = current_items_req[item_key]
		var item_name: String = item_data[0]
		var required_amount: int = item_data[1]
		
		# Skip empty item slots
		if item_name == "" or required_amount <= 0:
			continue
			
		var player_amount: int = SaveGame.get_item_count(item_name)
		if player_amount < required_amount:
			return false # Requirement not met
			
	# If loop completes, all requirements are met
	return true


# Helper function to disable the button (called after task completion)
func disable_button() -> void:
	button.disabled = true


# Helper function to reset internal state
func reset_state() -> void:
	current_task_id = -1
	current_items_req = {}
	current_money_reward = 0
	current_xp_reward = 0
	button.disabled = true
