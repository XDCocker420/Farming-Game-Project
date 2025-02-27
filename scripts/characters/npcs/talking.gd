extends State
class_name NPCTalking

var movement_speed: float = 200.0
var movement_target_position: Vector2 = Vector2(60.0,180.0)

@onready var navigation_agent: NavigationAgent2D = $"../../NavigationAgent2D"
@onready var character:CharacterBody2D = $"../.."
@onready var http_request:HTTPRequest = $HTTPRequest

	
func process_input(_event: InputEvent):
	if _event.is_action_pressed("interact"):
		http_request.request_completed.connect(_on_request_completed)

		# Define your API key and URL.
		var api_key = "AIzaSyB8ExehUd7ULav63SGT-ZLx_TuHxFa5zlc"  # Replace with your actual API key.
		var url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=" + api_key

		# Set up the headers.
		var headers = ["Content-Type: application/json"]

		# Build the JSON payload.
		var payload = {
			"contents": [{
				"parts": [{"text": "Explain how AI works"}]
			}]
		}
		# Convert the dictionary to a JSON string.
		var json_payload = JSON.stringify(payload)

		# Send the POST request.
		var error = http_request.request(url, headers, HTTPClient.METHOD_POST, json_payload)
		if error != OK:
			print("Error sending request: ", error)

# This function is called when the request is completed.
func _on_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var json = JSON.new()
		json.parse(body.get_string_from_utf8())
		var response = json.get_data()
		var data = response.candidates[0].content.parts[0].text
		if Dialogic.current_timeline != null:
			return
		
		var events : Array = """
		Jowan (Surprised): """ + PackedStringArray(data).split('\n')

		var timeline : DialogicTimeline = DialogicTimeline.new()
		timeline.events = events
		Dialogic.start(timeline)
	
		#Dialogic.start('chapterA')
		#get_viewport().set_input_as_handled()
