extends PanelContainer


signal buy

@onready var accept_button: TextureButton = $MarginContainer/VBoxContainer/HBoxContainer/accept
@onready var cancel_button: TextureButton = $MarginContainer/VBoxContainer/HBoxContainer/cancel
@onready var label: Label = $MarginContainer/VBoxContainer/Label

var can_buy = false
var price: int


func _ready() -> void:
    accept_button.pressed.connect(_on_accept)
    cancel_button.pressed.connect(_on_cancel)
    draw.connect(_check_price)
    

func _check_price():
    price = int(label.text.trim_suffix("$"))
    var money: int = SaveGame.get_money()
    if money >= price:
        can_buy = true
    else:
        can_buy = false
    

func _on_accept():
    if can_buy:
        buy.emit()
        SaveGame.remove_money(price)
        get_parent().hide()
        print(SaveGame.get_money())


func _on_cancel():
    get_parent().hide()
