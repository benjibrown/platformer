extends Node2D

var platforms: Array[StaticBody2D] = []
var next_x := 0.0
var next_y := 480.0
@onready var player: CharacterBody2D = $Player
@onready var camera: Camera2D = $Camera2D

func _ready() -> void:
	var bindings := {"left": [KEY_A, KEY_LEFT], "right": [KEY_D, KEY_RIGHT], "jump": [KEY_SPACE, KEY_W, KEY_UP], "restart": [KEY_R]}
	for action in bindings:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for key in bindings[action]:
			var event := InputEventKey.new()
			event.physical_keycode = key
			InputMap.action_add_event(action, event)
	player.fell.connect(_restart)
	_add_platform(600.0)
	_extend_level()

func _process(_delta: float) -> void:
	camera.position.x = maxf(480.0, player.position.x + 200.0)
	_extend_level()
	while platforms.size() > 0 and platforms[0].position.x < camera.position.x - 1200.0:
		platforms.pop_front().queue_free()
	if Input.is_action_just_pressed("restart"):
		_restart()

func _extend_level() -> void:
	while next_x < player.position.x + 1800.0:
		next_x += randf_range(75.0, 400.0)
		next_y = clampf(next_y + randf_range(-55.0, 55.0), 350.0, 500.0)
		_add_platform(randf_range(220.0, 380.0))

func _add_platform(width: float) -> void:
	var platform := StaticBody2D.new()
	platform.position = Vector2(next_x + width / 2.0, next_y + 12.0)
	var shape := RectangleShape2D.new()
	shape.size = Vector2(width, 24.0)
	var collision := CollisionShape2D.new()
	collision.shape = shape
	platform.add_child(collision)
	var sprite := Polygon2D.new()
	sprite.polygon = PackedVector2Array([Vector2(-width / 2.0, -12), Vector2(width / 2.0, -12), Vector2(width / 2.0, 12), Vector2(-width / 2.0, 12)])
	sprite.color = Color.WHITE
	platform.add_child(sprite)
	add_child(platform)
	platforms.append(platform)
	next_x += width

func _restart() -> void:
	get_tree().call_deferred("reload_current_scene")
