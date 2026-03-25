extends Node2D

const SPEED: float = 300.0
const GROUND_Y: float = 570.0
const SCREEN_W: float = 1280.0

var _speed: float = SPEED
var _active: bool = false
var _spawn_timer: float = 0.0
var _obs_timer: float = 0.0
var _next_spawn: float = 2.0
var _next_obs: float = 3.5
var _queue: Array = []
var _bg_w: float = 1280.0

var _col_textures = [
	"res://Assets/Sprites/Collectibles/aku.png",
	"res://Assets/Sprites/Collectibles/roboRIO.png",
	"res://Assets/Sprites/Collectibles/sparkmax.png",
	"res://Assets/Sprites/Collectibles/disli.png",
	"res://Assets/Sprites/Collectibles/kraken motor.png",
	"res://Assets/Sprites/Collectibles/neo motor.png",
	"res://Assets/Sprites/Collectibles/neo vortex.png",
	"res://Assets/Sprites/Collectibles/Power Distribution Pan.png"
]
var _obs_textures = [
	"res://Assets/Sprites/Obstacles/kemik.png",
	"res://Assets/Sprites/Obstacles/kaya.png",
	"res://Assets/Sprites/Obstacles/tank tekerlegi.png"
]

func _ready():
	_build_queue()
	_setup_bg()
	$HUD/GameOverPanel.visible = false
	$HUD/GameOverPanel/RestartBtn.pressed.connect(_restart)
	$HUD/DistanceLabel.text = "MESAFE: 0 m"
	$HUD/ScoreLabel.text = "PUAN: 0 / 80"
	_active = true

func _build_queue():
	_queue.clear()
	for t in _col_textures:
		_queue.append(t)
		_queue.append(t)
	_queue.shuffle()

func _setup_bg():
	var t1 = load("res://Assets/Sprites/Backgrounds/arka plan1.png")
	var t2 = load("res://Assets/Sprites/Backgrounds/arka plan2.png")
	if t1:
		$Backgrounds/BG1.texture = t1
		_bg_w = t1.get_width()
	if t2:
		$Backgrounds/BG2.texture = t2
	$Backgrounds/BG1.position = Vector2(_bg_w / 2.0, 360)
	$Backgrounds/BG2.position = Vector2(_bg_w * 1.5, 360)

func _process(delta: float):
	if not _active:
		return

	# Mesafe güncelle
	Global.distance += _speed * delta / 100.0
	$HUD/DistanceLabel.text = "MESAFE: %d m" % int(Global.distance)

	# Arka plan kaydır
	$Backgrounds/BG1.position.x -= _speed * delta
	$Backgrounds/BG2.position.x -= _speed * delta
	if $Backgrounds/BG1.position.x < -_bg_w / 2.0:
		$Backgrounds/BG1.position.x = $Backgrounds/BG2.position.x + _bg_w
	if $Backgrounds/BG2.position.x < -_bg_w / 2.0:
		$Backgrounds/BG2.position.x = $Backgrounds/BG1.position.x + _bg_w

	# Parça spawn
	_spawn_timer += delta
	if _spawn_timer >= _next_spawn and _queue.size() > 0:
		_spawn_timer = 0.0
		_next_spawn = randf_range(1.5, 3.5)
		_spawn_col()

	# Engel spawn
	_obs_timer += delta
	if _obs_timer >= _next_obs:
		_obs_timer = 0.0
		_next_obs = randf_range(2.0, 5.0)
		_spawn_obs()

	# Nesneleri hareket ettir ve çarpışma kontrol et
	var p_rect = Rect2($Player.position - Vector2(18, 35), Vector2(36, 55))
	for child in $Spawner.get_children():
		child.position.x -= _speed * delta
		if child.position.x < -150:
			child.queue_free()
			continue
		var o_rect = Rect2(child.position - Vector2(18, 18), Vector2(36, 36))
		if p_rect.intersects(o_rect):
			if child.get_meta("t") == "obs":
				_game_over()
				return
			elif child.get_meta("t") == "col":
				_collect(child)

func _spawn_col():
	if _queue.is_empty():
		return
	var path = _queue.pop_front()
	var s = Sprite2D.new()
	s.texture = load(path)
	s.scale = Vector2(0.5, 0.5)
	s.position = Vector2(SCREEN_W + 60, GROUND_Y - 20)
	s.set_meta("t", "col")
	$Spawner.add_child(s)

func _spawn_obs():
	var path = _obs_textures[randi() % _obs_textures.size()]
	var s = Sprite2D.new()
	s.texture = load(path)
	s.scale = Vector2(0.6, 0.6)
	s.position = Vector2(SCREEN_W + 60, GROUND_Y - 28)
	s.set_meta("t", "obs")
	$Spawner.add_child(s)

func _collect(node: Node):
	Global.score += 5
	Global.collected_parts += 1
	$HUD/ScoreLabel.text = "PUAN: %d / 80" % Global.score
	node.queue_free()
	if Global.collected_parts >= Global.TOTAL_PARTS:
		_win()

func _game_over():
	_active = false
	$Player.die()
	$HUD/GameOverPanel.visible = true

func _win():
	_active = false
	get_tree().change_scene_to_file("res://Assets/Scenes/Areas/win_screen.tscn")

func _restart():
	Global.reset()
	get_tree().change_scene_to_file("res://Assets/Scenes/Areas/Game.tscn")
