extends Node

@onready var slot = load('res://scenes/ui/ui_contractboard_slot.tscn')
@onready var btn = $"Menu/GridContainer/1"
@onready var out = $Menu/order_board/Label2
@onready var submit = $Menu/Button


var selection_highlight: NinePatchRect = null
var is_clicked = false
var current_id:int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	btn.button_group.pressed.connect(_on_button_pressed)
	submit.pressed.connect(_on_submit)
		
	if SaveGame.get_contracts().is_empty():
		for i in range(12):
			get_random_res(i+1)
			
	var count:int = 1
	for j in btn.button_group.get_buttons():
		var temp = SaveGame.get_contract_by_id(count)
		for k in j.get_children():
			k.text = str(temp.currency) + "\n" + str(temp.exp_val)
			var exp_icon = TextureRect.new()
			var money_icon = TextureRect.new()
			exp_icon.texture = load("res://assets/gui/icons/exp.png")
			money_icon.texture = load("res://assets/gui/icons/coin.png")
			
			money_icon.position = Vector2(17, 1)
			exp_icon.position = Vector2(17, 14)
			
			money_icon.scale = Vector2(0.15, 0.15)
			exp_icon.scale = Vector2(0.15, 0.15)
			k.add_child(money_icon)
			k.add_child(exp_icon)
		count += 1
		

func get_random_res(prev_id:int) -> SavedContracts:
	var items:Dictionary = {}
	var money:int = 0
	var exp_v:int = 0
	
	var all_items = ConfigReader.get_all_level()
	all_items.shuffle()
	
	var rng = RandomNumberGenerator.new()
	for i in range(rng.randi_range(2,5)):
		var rng_int:int = rng.randi_range(0, all_items.size() - 1)
		var count:int
		if ConfigReader.get_value(all_items[rng_int]) < 10:
			count = rng.randi_range(5,17)
		elif ConfigReader.get_value(all_items[rng_int]) >= 10:
			count = rng.randi_range(1,5)
		
		items[all_items.pop_at(rng_int)] = count
	
	for j in items.keys():
		exp_v += rng.randi_range(int(ConfigReader.get_exp(j) * 0.9), int(ConfigReader.get_exp(j) * 1.1)) * items[j]
		money += rng.randi_range(int(ConfigReader.get_value(j)), int(ConfigReader.get_max_price(j) * 0.7)) * items[j]
		
	SaveGame.add_contract(prev_id, exp_v, money, items)
	var temp:SavedContracts = SavedContracts.new()
	temp.id = prev_id
	temp.exp_val = exp_v
	temp.currency = money
	temp.req_res = items
	return temp


func check_inv(req_res:SavedContracts):
	var inv: = SaveGame.get_inventory()
	var temp:Array = []
	for i in req_res.req_res.keys():
		if i in inv.keys():
			if inv[i] >= req_res.req_res[i]:
				temp.append(i)
	temp.sort()
	var res = req_res.req_res.keys()
	res.sort()

	return temp.size() == res.size()

func _on_submit():
	var res = SaveGame.get_contract_by_id(current_id)
	for i in res.req_res.keys():
		SaveGame.remove_from_inventory(i, res.req_res[i])
	SaveGame.add_money(res.currency)
	SaveGame.add_experience_points(res.exp_val)
	SaveGame.remove_contract(SaveGame.get_contract_by_id(current_id))
	
	for j in out.get_children():
		out.remove_child(j)
	submit.disabled = true
	out.text = ""
	
	var item_pos:Vector2 = Vector2(0,0)
	var temp = get_random_res(current_id)
	var current_lbl = get_node("Menu/GridContainer/" + str(current_id) + "/Label")
	current_lbl.text = str(temp.currency) + "\n" + str(temp.exp_val)
	for i in temp.req_res.keys():
		_item_for_string(i, item_pos, temp.req_res[i])
		item_pos += Vector2(0 , 40)
		#out.text += i + "\n"
	if check_inv(temp):
		submit.disabled = false
	
	

func _on_button_pressed(knopf:TextureButton):
	for j in out.get_children():
		out.remove_child(j)
		
	current_id = int(str(knopf.name))
	var item_pos:Vector2 = Vector2(0,0)
	submit.disabled = true
	out.text = ""
	var temp = SaveGame.get_contract_by_id(int(str(knopf.name)))
	
	# For testing only REMOVE for production
	#for h in temp.req_res.keys():
	#	SaveGame.add_to_inventory(h, temp.req_res[h])
	
	for i in temp.req_res.keys():
		_item_for_string(i, item_pos, temp.req_res[i])
		item_pos += Vector2(0 , 40)
		#out.text += i + "\n"
	if check_inv(temp):
		submit.disabled = false
		
func _item_for_string(item:String, old_pos:Vector2, count:int):
	var temp = TextureRect.new()
	var lbl = Label.new()
	var path:String = ""
	if item != "sheep":
		path = "res://assets/gui/icons/" + item + ".png"
		temp.texture = load(path)
		temp.position = old_pos
		temp.scale = Vector2(2.3, 2.3)
		
		lbl.text = str(count)
		lbl.position += Vector2(20, -4)
		
		temp.add_child(lbl)
		out.add_child(temp)
	
	
