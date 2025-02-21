@tool
extends DialogicEvent
class_name DialogicTestEvent

# Define properties of the event here

func _execute() -> void:
	# This will execute when the event is reached
	finish() # called to continue with the next event


#region INITIALIZE
################################################################################
# Set fixed settings of this event
func _init() -> void:
	event_name = "Test"
	event_category = "Other"



#endregion

#region SAVING/LOADING
################################################################################
func get_shortcode() -> String:
	return "test"

func get_shortcode_parameters() -> Dictionary:
	return {
		#param_name 		: property_info
		#"my_parameter"		: {"property": "property", "default": "Default"},
	}

# You can alternatively overwrite these 3 functions: to_text(), from_text(), is_valid_event()
#endregion


#region EDITOR REPRESENTATION
################################################################################

func build_event_editor() -> void:
	pass

#endregion
