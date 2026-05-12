extends Node2D

const SPEED: float = 300.0
const GROUND_Y: float = 430.0
const SCREEN_W: float = 1280.0

var _speed: float = SPEED
var _active: bool = false
var _spawn_timer: float = 0.0
var _next_spawn: float = 2.0
var _bg_w: float = 1280.0

var _col_textures = [
	"res://Assets/Sprites/Collectibles/akü.png",
	"res://Assets/Sprites/Collectibles/disli.png",
	"res://Assets/Sprites/Collectibles/kraken motor.png",
	"res://Assets/Sprites/Collectibles/neo motor.png",
	"res://Assets/Sprites/Collectibles/neo vortex.png",
	"res://Assets/Sprites/Collectibles/Power Distribution Panel.png",
	"res://Assets/Sprites/Collectibles/roboRIO.png",
	"res://Assets/Sprites/Collectibles/sparkmax.png"
]
var _obs_textures = [
	"res://Assets/Sprites/Obstacles/kemik.png",
	"res://Assets/Sprites/Obstacles/kaya.png",
	"res://Assets/Sprites/Obstacles/tank tekerlegi.png"
]
var _obs_scales = [
	Vector2(0.9, 0.9),
	Vector2(0.9, 0.9),
	Vector2(1.6, 1.6)
]

# Kaç spawn'da bir engel çıkacak (geri kalanlar parça)
var _spawn_count: int = 0

func _ready():
	_setup_bg()
	_setup_hud()
	_active = true

func _setup_hud():
	var gap = _find_node("GameOverPanel")
	if gap:
		gap.visible = false

	var gol = _find_node("GameOverLabel")
	if gol:
		gol.text = "GAME OVER"

	var rb = _find_node("RestartBtn")
	if rb:
		rb.text = "Restart"
		rb.pressed.connect(_restart)

	var dl = _find_node("DistanceLabel")
	if dl:
		dl.text = "Distance: 0 m"

	var sl = _find_node("ScoreLabel")
	if sl:
		sl.text = "Score: 0"

func _setup_bg():
	var bg1 = _find_node("BG1")
	var bg2 = _find_node("BG2")
	var t1 = load("res://Assets/Sprites/Backgrounds/arka plan1.png")
	var t2 = load("res://Assets/Sprites/Backgrounds/arka plan2.png")
	if bg1 and t1:
		bg1.texture = t1
		_bg_w = t1.get_width()
		bg1.position = Vector2(_bg_w / 2.0, 360)
	if bg2 and t2:
		bg2.texture = t2
		bg2.position = Vector2(_bg_w * 1.5, 360)

func _process(delta: float):
	if not _active:
		return

	Global.distance += _speed * delta / 100.0
	var dl = _find_node("DistanceLabel")
	if dl:
		dl.text = "Distance: %d m" % int(Global.distance)

	var bg1 = _find_node("BG1")
	var bg2 = _find_node("BG2")
	if bg1 and bg2:
		bg1.position.x -= _speed * delta
		bg2.position.x -= _speed * delta
		if bg1.position.x < -_bg_w / 2.0:
			bg1.position.x = bg2.position.x + _bg_w
		if bg2.position.x < -_bg_w / 2.0:
			bg2.position.x = bg1.position.x + _bg_w

	# TEK spawn sistemi — her seferinde sadece 1 nesne çıkar
	_spawn_timer += delta
	if _spawn_timer >= _next_spawn:
		_spawn_timer = 0.0
		_next_spawn = randf_range(1.8, 3.5)
		_spawn_count += 1
		# Her 3 spawn'dan 1'i engel, 2'si parça
		if _spawn_count % 3 == 0:
			_spawn_obs()
		else:
			_spawn_col()

	var spawner = _find_node("Spawner")
	var player = _find_node("Player")
	if not spawner or not player:
		return

	var p_rect = Rect2(player.position - Vector2(18, 35), Vector2(36, 55))
	for child in spawner.get_children():
		child.position.x -= _speed * delta
		if child.position.x < -150:
			child.queue_free()
			continue
		var o_rect = Rect2(child.position - Vector2(25, 25), Vector2(50, 50))
		if p_rect.intersects(o_rect):
			if child.get_meta("t") == "obs":
				_game_over()
				return
			elif child.get_meta("t") == "col":
				_collect(child)

func _spawn_col():
	var spawner = _find_node("Spawner")
	if not spawner:
		return
	var path = _col_textures[randi() % _col_textures.size()]
	var tex = load(path)
	if not tex:
		return
	var s = Sprite2D.new()
	s.texture = tex
	s.scale = Vector2(0.8, 0.8)
	s.position = Vector2(SCREEN_W + 60, GROUND_Y)
	s.set_meta("t", "col")
	spawner.add_child(s)

func _spawn_obs():
	var spawner = _find_node("Spawner")
	if not spawner:
		return
	var idx = randi() % _obs_textures.size()
	var tex = load(_obs_textures[idx])
	if not tex:
		return
	var s = Sprite2D.new()
	s.texture = tex
	s.scale = _obs_scales[idx]
	s.position = Vector2(SCREEN_W + 60, GROUND_Y)
	s.set_meta("t", "obs")
	spawner.add_child(s)

func _collect(node: Node):
	Global.score += 5
	var sl = _find_node("ScoreLabel")
	if sl:
		sl.text = "Score: %d" % Global.score
	node.queue_free()

func _game_over():
	_active = false
	var player = _find_node("Player")
	if player and player.has_method("die"):
		player.die()
	var gap = _find_node("GameOverPanel")
	if gap:
		gap.visible = true

func _restart():
	Global.reset()
	get_tree().change_scene_to_file("res://Assets/Scenes/Areas/Game.tscn")

func _find_node(target: String) -> Node:
	return _search(self, target)

func _search(node: Node, target: String) -> Node:
	if node.name == target:
		return node
	for c in node.get_children():
		var r = _search(c, target)
		if r:
			return r
	return null
