extends Node2D

var bg1: Sprite2D
var bg2: Sprite2D
var bg_width: float = 1280.0

func _ready() -> void:
	var tex1 = load("res://Assets/Sprites/Backgrounds/arka plan1.png") as Texture2D
	var tex2 = load("res://Assets/Sprites/Backgrounds/arka plan2.png") as Texture2D

	bg1 = Sprite2D.new()
	bg1.centered = false
	bg1.texture = tex1
	add_child(bg1)

	bg2 = Sprite2D.new()
	bg2.centered = false
	bg2.texture = tex2
	add_child(bg2)

	if tex1:
		bg1.scale = Vector2(1280.0 / tex1.get_width(), 720.0 / tex1.get_height())
	if tex2:
		bg2.scale = Vector2(1280.0 / tex2.get_width(), 720.0 / tex2.get_height())

	bg_width = 1280.0
	bg2.position.x = bg_width

func _process(delta: float) -> void:
	if Global.is_game_over:
		return

	var scroll = Global.game_speed * delta * 0.5
	bg1.position.x -= scroll
	bg2.position.x -= scroll

	if bg1.position.x + bg_width <= 0:
		bg1.position.x = bg2.position.x + bg_width
	if bg2.position.x + bg_width <= 0:
		bg2.position.x = bg1.position.x + bg_width
