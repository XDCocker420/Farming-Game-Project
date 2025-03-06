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
	print(argument)
	if argument == "trigger_ai":
		# Define your API key and URL.
		var api_key = "API_KEY"  # Replace with your actual API key.
		var url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=" + api_key

		# Set up the headers.
		var headers = ["Content-Type: application/json"]

		# Build the JSON payload.
		var payload = {
			"contents": [{
				"parts": [{"text": Dialogic.VAR.inputs.custom_question + "Die Ausgabe soll maximal 30 Wörter haben"}]
			}]
		}
		
		# Convert the dictionary to a JSON string.
		var json_payload = JSON.stringify(payload)

		# Send the POST request.
		var error = http_request.request(url, headers, HTTPClient.METHOD_POST, json_payload)
		if error != OK:
			print("Error sending request: ", error)
			
		
		http_request.request_completed.connect(_on_request_completed)
	
	
func process_input(_event: InputEvent):
	if _event.is_action_pressed("interact") && Dialogic.current_timeline == null:
		var timeline : DialogicTimeline = load("res://dialogs/timelines/talking1.dtl")
		timeline.from_text("""
		join starter center
		starter: Howdy Freund. Wie gehts?
		label choice
		starter: Was möchtest du über das Spiel wissen?
		- Wie geht es dir?
			starter: Mir gehts super!!
			jump choice
		- Wie bekomme ich mehr Pflanzen?
			starter: Du musst einfach hoffen, dass der Bill das einbaut
			jump choice
		- Wie funktionieren die Tiere?
			starter: Man geht zu den Futterplätzen und drückt die E Taste
			jump choice
		- Ich will selber etwas fragen
			[text_input var="inputs.custom_question"]
			[signal arg="trigger_ai"]
			label loop1
			if {inputs.custom_answer} == "":
				[wait time="0.5"]
				jump loop1
			starter: {inputs.custom_answer}
			jump choice
		- Danke ich hab keine Fragen mehr
			[end_timeline]
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
