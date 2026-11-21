extends CharacterBody2D

var hp := 100
var facing := 1
var combo := 0
var attack_time := 0.0
var hit_done := false
var queued := false
var invulnerable := 0.0
var dead := false

const SPEED := 190.0
const JUMP := -562.5
const GRAVITY := 1758.0
const DAMAGE := [10, 10, 15]
const DURATIONS := [0.45, 0.41, 0.65]
const WINDUPS := [0.12, 0.11, 0.18]
const ACTIVE := [0.10, 0.10, 0.12]

var attack_was_pressed := false
var jump_was_pressed := false
var sprite: AnimatedSprite2D

func _ready() -> void:
	var shape := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = Vector2(26, 68)
	shape.position.y = -34
	shape.shape = box
	add_child(shape)
	sprite = AnimatedSprite2D.new()
	sprite.name = "AnimatedSprite2D"
	sprite.position.y = -37
	sprite.scale = Vector2(0.115, 0.115)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var frames := SpriteFrames.new()
	frames.add_animation("idle")
	frames.set_animation_speed("idle", 4.0)
	frames.set_animation_loop("idle", true)
	for i in range(1, 9):
		var texture: Texture2D = load("res://assets/madero/idle/madero_idle_%02d.png" % i)
		frames.add_frame("idle", texture)
	sprite.sprite_frames = frames
	add_child(sprite)
	sprite.play("idle")

func _physics_process(delta: float) -> void:
	if dead:
		return
	invulnerable = maxf(0.0, invulnerable - delta)
	var attack_down := Input.is_key_pressed(KEY_D)
	var jump_down := Input.is_key_pressed(KEY_W)
	var attack_just_pressed := attack_down and not attack_was_pressed
	var jump_just_pressed := jump_down and not jump_was_pressed
	attack_was_pressed = attack_down
	jump_was_pressed = jump_down
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	var axis := 0.0
	if Input.is_key_pressed(KEY_RIGHT):
		axis += 1.0
	if Input.is_key_pressed(KEY_LEFT):
		axis -= 1.0
	if axis != 0 and combo == 0:
		facing = int(sign(axis))
	if combo > 0:
		_process_combo(delta, axis, attack_just_pressed, jump_just_pressed)
	else:
		velocity.x = move_toward(velocity.x, axis * SPEED, 1400.0 * delta)
		if jump_just_pressed and is_on_floor():
			velocity.y = JUMP
		if attack_just_pressed:
			_start_attack(1)
	move_and_slide()
	sprite.flip_h = facing < 0
	sprite.modulate.a = 0.45 if invulnerable > 0.0 and int(invulnerable * 20.0) % 2 == 0 else 1.0

func _process_combo(delta: float, axis: float, attack_pressed: bool, jump_pressed: bool) -> void:
	var idx := combo - 1
	attack_time += delta
	if attack_pressed and combo < 3:
		queued = true
	if not hit_done and attack_time >= WINDUPS[idx]:
		hit_done = true
		_hit_guard(idx)
	if combo == 3 and attack_time <= 0.16:
		velocity.x = facing * 175.0
	else:
		velocity.x = axis * SPEED * 0.4
	var active_end: float = WINDUPS[idx] + ACTIVE[idx]
	if jump_pressed and is_on_floor() and attack_time >= active_end:
		velocity.y = JUMP
		_reset_combo()
		return
	if attack_time >= DURATIONS[idx]:
		if queued and combo < 3:
			_start_attack(combo + 1)
		else:
			_reset_combo()

func _hit_guard(idx: int) -> void:
	var enemy = get_parent().guard
	if not is_instance_valid(enemy) or enemy.hp <= 0:
		return
	var dx: float = enemy.position.x - position.x
	var dy: float = enemy.position.y - position.y
	if absf(dx) <= 69 and absf(dy) < 55 and dx * facing > 0:
		enemy.take_hit(DAMAGE[idx], facing)

func _start_attack(number: int) -> void:
	combo = number
	attack_time = 0.0
	hit_done = false
	queued = false

func _reset_combo() -> void:
	combo = 0
	attack_time = 0.0
	hit_done = false
	queued = false

func take_hit(damage: int, direction: int) -> void:
	if invulnerable > 0 or dead:
		return
	hp = maxi(0, hp - damage)
	invulnerable = 0.6
	_reset_combo()
	velocity.x = direction * 90.0
	if hp <= 0:
		dead = true
	queue_redraw()
