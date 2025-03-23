extends PanelContainer


@onready var accept_button: TextureButton = $MarginContainer/VBoxContainer/HBoxContainer/accept
@onready var cancel_button: TextureButton = $MarginContainer/VBoxContainer/HBoxContainer/cancel
@onready var label: Label = $MarginContainer/VBoxContainer/Label

var price: int
var can_buy = false


func _ready() -> void:
    accept_button.pressed.connect(_on_accept)
    cancel_button.pressed.connect(_on_cancel)
    

func _check_price():
    price = int(label.text.trim_suffix("$"))
    print(price)
    

func _on_accept():
    pass    


func _on_cancel():
    pass
