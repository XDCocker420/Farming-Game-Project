extends State
class_name NPCTalking

var movement_speed: float = 200.0
var movement_target_position: Vector2 = Vector2(60.0,180.0)

@onready var navigation_agent: NavigationAgent2D = $"../../NavigationAgent2D"
@onready var character:CharacterBody2D = $"../.."
@onready var http_request:HTTPRequest = $HTTPRequest


func _ready() -> void:
	Dialogic.signal_event.connect(_on_dialogic_signal)

func _on_dialogic_signal(argument:String):
	if argument == "exit_dialog":
		transitioned.emit(self, "Wandering")
	if argument == "trigger_ai":
		
		# Define your API key and URL.
		var api_key = ConfigReader.get_api_key()
		var url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=" + api_key

		# Set up the headers.
		var headers = ["Content-Type: application/json"]

		# Build the JSON payload.
		var payload = {
			"contents": [{
				"parts": [{"text": Dialogic.VAR.inputs.custom_question + " The output should have a maximum of 30 words"}]
			}]
		}
		
		# Convert the dictionary to a JSON string.
		var json_payload = JSON.stringify(payload)

		# Send the POST request.
		var error = http_request.request(url, headers, HTTPClient.METHOD_POST, json_payload)
		if error != OK:
			print("Error sending request: ", error)
			
		
		http_request.request_completed.connect(_on_request_completed)
	
		
func enter() -> void:
	var timeline : DialogicTimeline = load("res://dialogs/timelines/talking1.dtl")
	timeline.from_text("""
		join starter center
		starter: What would you like to know about the game?
		label choice
		starter: What would you like to know about the game?
		- How are you?
			starter: I'm doing great!!
			jump choice
		- How do I get more plants?
			starter: You just have to hope that Bill implements that
			jump choice
		- How do the animals work?
			starter: You go to the feeding places and press the E key
			jump choice
		- I want to ask something myself
			[text_input text="Ask your question:" var="inputs.custom_question"]
			[signal arg="trigger_ai"]
			label loop1
			if {inputs.custom_answer} == "":
				[wait time="0.5"]
				jump loop1
			starter: {inputs.custom_answer}
			jump choice
		- Thanks, I have no more questions
			[end_timeline]
			[signal arg="exit_dialog"]
		""")
	timeline.process()
	Dialogic.start(timeline)
		

# This function is called when the request is completed.
func _on_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var json = JSON.new()
		json.parse(body.get_string_from_utf8())
		var response = json.get_data()
		var data = response.candidates[0].content.parts[0].text
		Dialogic.VAR.inputs.custom_answer = data

func start_talking():
	starter: What would you like to know about the game?
	
	
func send_ai(player_name: String) -> void:
