extends CharacterBody2D

signal fell

const SPEED := 700.0
const JUMP_SPEED := -650.0
const GRAVITY := 1800.0
var coyote_time := 0.0
var jump_buffer := 0.0
var active := true

func _physics_process(delta: float) -> void:
	if not active:
		return
	coyote_time = 0.10 if is_on_floor() else maxf(0.0, coyote_time - delta)
	jump_buffer = maxf(0.0, jump_buffer - delta)
	if Input.is_action_just_pressed("jump"):
		jump_buffer = 0.12
	var direction := Input.get_axis("left", "right")
	velocity.x = move_toward(velocity.x, direction * SPEED, 2200.0 * delta)
	velocity.y += GRAVITY * delta
	if jump_buffer > 0.0 and coyote_time > 0.0:
		velocity.y = JUMP_SPEED
		jump_buffer = 0.0
		coyote_time = 0.0
	if Input.is_action_just_released("jump") and velocity.y < -250.0:
		velocity.y = -250.0
	if direction != 0.0:
		$Sprite2D.flip_h = direction < 0.0
	move_and_slide()
	if position.y > 780.0:
		fell.emit()
