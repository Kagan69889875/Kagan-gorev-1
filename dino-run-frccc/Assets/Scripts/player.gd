extends CharacterBody2D

# Eğer karakterin 4'ten fazla frame'i varsa burayı değiştir (4, 5 veya 6)
const FRAME_COUNT: int = 4
const JUMP_FORCE: float = -650.0
const GRAVITY: float = 1800.0

var _dead: bool = false

func _ready():
	_setup_animation()

func _setup_animation():
	var tex_path: String
	match Global.selected_character:
		"Dino":
			tex_path = "res://Assets/Sprites/Characters/Dino animasyon.png"
		"Mumya":
			tex_path = "res://Assets/Sprites/Characters/Mumya animasyon.png"
		"Stegosaurus":
			tex_path = "res://Assets/Sprites/Characters/stegosaurus animasyon.png"
		_:
			tex_path = "res://Assets/Sprites/Characters/Dino animasyon.png"

	var texture = load(tex_path)
	if not texture:
		return

	var fw: int = int(texture.get_width() / FRAME_COUNT)
	var fh: int = texture.get_height()
	var sf = SpriteFrames.new()

	# Koşma animasyonu
	sf.add_animation("run")
	sf.set_animation_speed("run", 10.0)
	sf.set_animation_loop("run", true)
	for i in range(FRAME_COUNT):
		var a = AtlasTexture.new()
		a.atlas = texture
		a.region = Rect2(i * fw, 0, fw, fh)
		sf.add_frame("run", a)

	# Zıplama animasyonu (son frame)
	sf.add_animation("jump")
	sf.set_animation_speed("jump", 1.0)
	sf.set_animation_loop("jump", false)
	var ja = AtlasTexture.new()
	ja.atlas = texture
	ja.region = Rect2((FRAME_COUNT - 1) * fw, 0, fw, fh)
	sf.add_frame("jump", ja)

	$Sprite.sprite_frames = sf
	$Sprite.play("run")

func _physics_process(delta: float):
	if _dead:
		return
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		if $Sprite.animation == "jump":
			$Sprite.play("run")
	if (Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_up")) and is_on_floor():
		velocity.y = JUMP_FORCE
		$Sprite.play("jump")
	move_and_slide()

func die():
	_dead = true
	velocity = Vector2.ZERO
	$Sprite.stop()
