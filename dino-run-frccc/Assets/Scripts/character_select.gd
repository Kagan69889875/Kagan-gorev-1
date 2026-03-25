extends Control

func _ready():
	Global.reset()
	var all_buttons = _get_all_buttons(self)
	for btn in all_buttons:
		var n = btn.name.to_lower()
		if "dino" in n:
			btn.pressed.connect(func(): _select("Dino"))
		elif "mumya" in n:
			btn.pressed.connect(func(): _select("Mumya"))
		elif "stego" in n:
			btn.pressed.connect(func(): _select("Stegosaurus"))

func _get_all_buttons(node: Node) -> Array:
	var result = []
	if node is Button:
		result.append(node)
	for child in node.get_children():
		result += _get_all_buttons(child)
	return result

func _select(char_name: String):
	Global.selected_character = char_name
	print("Secildi: ", char_name)

func _on_start_btn_pressed() -> void:
	print("BASLA basildi!")
	get_tree().change_scene_to_file("res://Assets/Scenes/Areas/Game.tscn")
