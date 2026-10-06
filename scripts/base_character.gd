class_name BaseCharacter
extends CharacterBody3D

## Y rotation of the Direction node for each facing.
## A Node3D looks along -Z, and the topdown camera sits on +Z, so -Z is "up" on screen.
const DIRECTION_YAW: Dictionary = {
	"up": 0.0,
	"left": PI / 2,
	"down": PI,
	"right": -PI / 2,
}

## The opposite facing, used by turn_around().
const OPPOSITE_DIRECTION: Dictionary = {
	"up": "down",
	"down": "up",
	"left": "right",
	"right": "left",
}

@export var movement_speed: float = 6.0
@export var sprint_multiplier: float = 1.6
@export var gravity: float = 24.0
@export var direction: String = "down"
@export var jump_count: int = 2
@export var coyote_time: float = 0.1
@export var wall_slide_speed: float = 2.0
@export var wall_jump_push: float = 7.0
@export var spawn_point: Node3D

var wall_jump_lock: float = 0.0
var max_fall_speed: float = INF
var time_in_air :float = 0.0
var jump_speed: float = 12.0
var fsm: FSM = null
var current_animation = null
var air_jump_count: int = 0

@onready var sprite: Sprite3D = $Sprite3D
@onready var anim_player: AnimationPlayer = $AnimationPlayer

var _next_animation = null
var _next_direction: String = "down"
var _played_direction: String = ""

func _ready() -> void:
	_next_direction = direction

func _physics_process(delta: float) -> void:
	_check_changed_animation()
	if is_on_floor():
		time_in_air = 0.0
		air_jump_count = jump_count
	else:
		time_in_air += delta
	wall_jump_lock = maxf(wall_jump_lock - delta, 0.0)
	if fsm != null:
		fsm._update(delta)
	_update_movement(delta)
	_check_changed_direction()

func _update_movement(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
		velocity.y = maxf(velocity.y, -max_fall_speed)
	move_and_slide()
	pass

# Pick the facing from the input vector: whichever axis is stronger wins
static func direction_from_input(input: Vector2) -> String:
	if absf(input.x) > absf(input.y):
		return "right" if input.x > 0.0 else "left"
	return "down" if input.y > 0.0 else "up"

func turn_around() -> void:
	if _next_direction != direction:
		return
	_next_direction = OPPOSITE_DIRECTION[direction]

func is_left() -> bool:
	return direction == "left"

func is_right() -> bool:
	return direction == "right"

func turn_left() -> void:
	_next_direction = "left"

func turn_right() -> void:
	_next_direction = "right"

func turn_up() -> void:
	_next_direction = "up"

func turn_down() -> void:
	_next_direction = "down"

func jump() -> void:
	velocity.y = jump_speed

func stop_move() -> void:
	velocity = Vector3.ZERO

# Stop horizontal movement, keep the falling velocity
func stop_horizontal() -> void:
	velocity.x = 0.0
	velocity.z = 0.0

func change_animation(new_animation: String) -> void:
	_next_animation = new_animation

func change_direction(new_direction: String) -> void:
	_next_direction = new_direction

# The actual animation name played on AnimationPlayer, e.g. "run" + "left" -> "run_left"
func get_animation_name() -> String:
	if current_animation == null:
		return ""
	return "%s_%s" % [current_animation, direction]

func _check_changed_animation() -> void:
	var need_play: bool = false
	if _next_animation != current_animation:
		current_animation = _next_animation
		need_play = true
	# Changing facing must replay the animation too: each facing is its own animation
	if direction != _played_direction:
		_played_direction = direction
		need_play = true
	if need_play and anim_player != null and current_animation != null:
		anim_player.play(get_animation_name())

func _check_changed_direction() -> void:
	if _next_direction != direction:
		direction = _next_direction
		_on_changed_direction()

func _on_changed_direction() -> void:
	pass

func can_coyote() -> bool:
	return is_on_floor() or time_in_air < coyote_time

func ground_jump() -> void:
	if not can_coyote():
		return
	jump()

func can_air_jump() -> bool:
	return not is_on_floor() and air_jump_count > 0

func air_jump() -> void:
	if not can_air_jump():
		return
	jump()
	air_jump_count -= 1

func is_running(is_run: bool) -> void:
	if is_run:
		anim_player.speed_scale = sprint_multiplier
	else:
		anim_player.speed_scale = 1.0

func wall_jump() -> void:
	var n := get_wall_normal()
	velocity.x = n.x * wall_jump_push
	velocity.z = n.z * wall_jump_push
	velocity.y = jump_speed
	wall_jump_lock = 0.2

func respawn() -> void:
	global_position = spawn_point.position
	velocity = Vector3.ZERO
	max_fall_speed = INF
