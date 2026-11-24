extends CharacterBody2D

const SPEED: float = 300.0
const JUMP_VELOCITY: float = -400.0
const SLEEP_TIME: float = 5.0
const SLEEP_ANIMATION: StringName = &"sleeping"

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var inactivity_timer: Timer
var is_sleeping: bool = false


func _ready() -> void:
	inactivity_timer = Timer.new()
	inactivity_timer.wait_time = SLEEP_TIME
	inactivity_timer.one_shot = true
	inactivity_timer.timeout.connect(_on_inactivity_timeout)
	add_child(inactivity_timer)
	inactivity_timer.start()


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	var direction := Input.get_axis("move_left", "move_right")
	var has_input := direction != 0 or Input.is_action_pressed("jump")
	if has_input:
		is_sleeping = false
		inactivity_timer.start-()

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		animated_sprite.play("run")

	if direction != 0:
		velocity.x = direction * SPEED
		animated_sprite.play("run")
		animated_sprite.flip_h = direction < 0
	elif not is_sleeping:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		animated_sprite.play("idle")

	move_and_slide()


func _on_inactivity_timeout() -> void:
	if is_on_floor() and velocity.x == 0 and animated_sprite.sprite_frames.has_animation(SLEEP_ANIMATION):
		is_sleeping = true
		animated_sprite.play(SLEEP_ANIMATION)
