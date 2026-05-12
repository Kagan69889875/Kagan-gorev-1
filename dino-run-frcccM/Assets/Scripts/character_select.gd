extends Control

func _ready():
	Global.reset()
	_setup_previews()
	_connect_buttons()

func _setup_previews():
	var chars = {
		"DinoPreview": "res://Assets/Sprites/Characters/Dino animasyon.png",
		"MumyaPreview": "res://Assets/Sprites/Characters/Mumya animasyon.png",
		"StegoPreview": "res://Assets/Sprites/Characters/stegosaurus animasyon.png"
	}
	for node_name in chars:
		var node = _find(node_name)
		if not node:
			continue
		var tex = load(chars[node_name])
		if not tex:
			continue
		var atlas = AtlasTexture.new()
		atlas.atlas = tex
		atlas.region = Rect2(0, 0, tex.get_width() / 4.0, tex.get_height())
		if node is TextureRect:
			node.texture = atlas

func _connect_buttons():
	var buttons = {
		"DinoBtn": "Dino",
		"MumyaBtn": "Mumya",
		"StegoBtn": "Stegosaurus"
	}
	for btn_name in buttons:
		var btn = _find(btn_name)
		if btn is Button:
			var char_name = buttons[btn_name]
			btn.pressed.connect(func():
				Global.selected_character = char_name
				get_tree().change_scene_to_file("res://Assets/Scenes/Areas/Game.tscn")
			)

func _find(target: String) -> Node:
	return _search(self, target)

func _search(node: Node, target: String) -> Node:
	if node.name == target:
		return node
	for c in node.get_children():
		var r = _search(c, target)
		if r:
			return r
	return null
