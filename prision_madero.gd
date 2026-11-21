extends Node2D

var guard: CharacterBody2D
var madero: CharacterBody2D
var notice: Label

func _ready() -> void:
	_build_background()
	_build_floor()
	madero = CharacterBody2D.new()
	madero.name = "Madero"
	madero.set_script(load("res://scripts/madero.gd"))
	madero.position = Vector2(110, 320)
	add_child(madero)
	guard = CharacterBody2D.new()
	guard.name = "Guardia"
	guard.set_script(load("res://scripts/guardia.gd"))
	guard.position = Vector2(425, 320)
	add_child(guard)
	guard.target = madero
	var layer := CanvasLayer.new()
	add_child(layer)
	notice = Label.new()
	notice.position = Vector2(14, 10)
	notice.add_theme_font_size_override("font_size", 13)
	layer.add_child(notice)

func _process(_delta: float) -> void:
	if is_instance_valid(madero) and is_instance_valid(guard):
		notice.text = "MADERO %d HP   |   GUARDIA %d HP\nFLECHAS: mover  |  W: saltar  |  D: atacar  |  R: reiniciar" % [madero.hp, guard.hp]
	if Input.is_key_pressed(KEY_R):
		get_tree().reload_current_scene()

func _build_floor() -> void:
	var floor_body := StaticBody2D.new()
	floor_body.name = "Suelo"
	floor_body.position = Vector2(320, 340)
	add_child(floor_body)
	var collision := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(1200, 40)
	collision.shape = rectangle
	floor_body.add_child(collision)
	var visual := Polygon2D.new()
	visual.polygon = PackedVector2Array([Vector2(-600,-20),Vector2(600,-20),Vector2(600,20),Vector2(-600,20)])
	visual.color = Color("594a40")
	floor_body.add_child(visual)

func _build_background() -> void:
	var backdrop := Polygon2D.new()
	backdrop.polygon = PackedVector2Array([Vector2(-100,-50),Vector2(900,-50),Vector2(900,320),Vector2(-100,320)])
	backdrop.color = Color("24212a")
	add_child(backdrop)
	for i in range(8):
		var column := Polygon2D.new()
		var x := float(i) * 115.0 - 40.0
		column.polygon = PackedVector2Array([Vector2(x,45),Vector2(x+15,45),Vector2(x+15,320),Vector2(x,320)])
		column.color = Color("39313a")
		add_child(column)
	for i in range(5):
		var bar := Polygon2D.new()
		var x := float(i) * 160.0 + 15.0
		bar.polygon = PackedVector2Array([Vector2(x,95),Vector2(x+3,95),Vector2(x+3,280),Vector2(x,280)])
		bar.color = Color("16171d")
		add_child(bar)
