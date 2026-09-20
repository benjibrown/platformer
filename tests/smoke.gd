extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _frames(count: int) -> void:
	for i in range(count):
		await physics_frame

func _run() -> void:
	seed(42)
	var game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await _frames(30)
	assert(game.player.is_on_floor())
	assert(game.player.get_node("Sprite2D").texture.get_image().detect_alpha() != Image.ALPHA_NONE)
	for i in range(20):
		var start: StaticBody2D = game.platforms[0]
		var target: StaticBody2D = game.platforms[1]
		var width: float = start.get_node("CollisionShape2D").shape.size.x if start.has_node("CollisionShape2D") else start.get_child(0).shape.size.x
		game.player.position = Vector2(start.position.x + width / 2.0 - 38.0, start.position.y - 50.0)
		game.player.velocity = Vector2.ZERO
		await _frames(12)
		Input.action_press("right")
		Input.action_press("jump")
		await _frames(42)
		Input.action_release("jump")
		Input.action_release("right")
		await _frames(20)
		assert(game.player.is_on_floor(), "Failed jump %d" % i)
		assert(game.player.position.x > target.position.x - target.get_child(0).shape.size.x / 2.0)
		game.platforms.pop_front().queue_free()
	assert(game.next_x > 6000.0)
	assert(game.platforms.size() < 12)
	game.player.position.y = 900.0
	await _frames(10)
	assert(current_scene != game)
	assert(current_scene.player.position.x == 120.0)
	print("PASS: transparent cat, 20 generated jumps, bounded platforms, automatic restart")
	quit()
