extends CharacterBody2D

var target: CharacterBody2D
var hp := 30
var facing := -1
var attack_clock := 0.0
var stagger := 0.0
const GRAVITY := 1758.0

func _ready() -> void:
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(27, 68)
	collision.position.y = -34
	collision.shape = shape
	add_child(collision)

func _physics_process(delta: float) -> void:
	if hp <= 0:
		queue_redraw()
		return
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	if stagger > 0.0:
		stagger -= delta
		velocity.x = move_toward(velocity.x, 0.0, 500.0 * delta)
	elif is_instance_valid(target) and not target.dead:
		var dx: float = target.position.x - position.x
		facing = 1 if dx > 0 else -1
		velocity.x = facing * 60.0 if absf(dx) > 54 else 0.0
		attack_clock -= delta
		if absf(dx) <= 54 and absf(target.position.y - position.y) < 45 and attack_clock <= 0.0:
			target.take_hit(8, facing)
			attack_clock = 1.25
	move_and_slide()
	queue_redraw()

func take_hit(damage: int, direction: int) -> void:
	hp = maxi(0, hp - damage)
	stagger = 0.25
	velocity.x = direction * 100.0
	queue_redraw()

func _draw() -> void:
	if hp <= 0:
		draw_rect(Rect2(-30,-9,60,9), Color("4a3131"))
		return
	draw_rect(Rect2(-12,-48,24,35), Color("435061"))
	draw_rect(Rect2(-10,-67,20,19), Color("ba9176"))
	draw_rect(Rect2(-12,-70,24,7), Color("272e38"))
	draw_rect(Rect2(-12,-13,10,13), Color("30343b"))
	draw_rect(Rect2(2,-13,10,13), Color("30343b"))
	draw_line(Vector2(facing*9,-40),Vector2(facing*27,-23),Color("9e805a"),4)
