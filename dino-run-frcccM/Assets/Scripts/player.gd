extends CharacterBody2D

const JUMP_FORCE: float = -650.0
const GRAVITY: float = 1800.0

const FRAME_W: int = 128
const FRAME_H: int = 128

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

	var sf = SpriteFrames.new()

	# Koşma — frame 0 ve 1
	sf.add_animation("run")
	sf.set_animation_speed("run", 6.0)
	sf.set_animation_loop("run", true)
	for i in range(2):
		var a = AtlasTexture.new()
		a.atlas = texture
		a.region = Rect2(i * FRAME_W, 0, FRAME_W, FRAME_H)
		sf.add_frame("run", a)

	# Düşme — frame 2
	sf.add_animation("fall")
	sf.set_animation_speed("fall", 1.0)
	sf.set_animation_loop("fall", false)
	var fa = AtlasTexture.new()
	fa.atlas = texture
	fa.region = Rect2(2 * FRAME_W, 0, FRAME_W, FRAME_H)
	sf.add_frame("fall", fa)

	# Zıplama — frame 3
	sf.add_animation("jump")
	sf.set_animation_speed("jump", 1.0)
	sf.set_animation_loop("jump", false)
	var ja = AtlasTexture.new()
	ja.atlas = texture
	ja.region = Rect2(3 * FRAME_W, 0, FRAME_W, FRAME_H)
	sf.add_frame("jump", ja)

	$Sprite.sprite_frames = sf
	$Sprite.play("run")

func _physics_process(delta: float):
	if _dead:
		return
	if not is_on_floor():
		velocity.y += GRAVITY * delta
		if velocity.y < 0:
			if $Sprite.animation != "jump":
				$Sprite.play("jump")
		else:
			if $Sprite.animation != "fall":
				$Sprite.play("fall")
	else:
		if $Sprite.animation != "run":
			$Sprite.play("run")
	if (Input.is_action_just_pressed("ui_accept") or \
		Input.is_action_just_pressed("ui_up")) and is_on_floor():
		velocity.y = JUMP_FORCE
	move_and_slide()

func _input(event):
	if event is InputEventScreenTouch and event.pressed:
		if is_on_floor() and not _dead:
			velocity.y = JUMP_FORCE
			$Sprite.play("jump")

func die():
	_dead = true
	velocity = Vector2.ZERO
	$Sprite.stop()
