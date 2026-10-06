class_name PlayerState
extends FSMState

func _enter() -> void:
	pass

func _exit() -> void:
	pass

func _update(delta: float) -> void:
	pass

#Control moving and changing state to run
#Return true if moving
func control_moving() -> bool:
	var input: Vector2 = Input.get_vector("left", "right", "up", "down")
	var is_moving: bool = input.length() > 0.1
	if is_moving:
		obj.change_direction(BaseCharacter.direction_from_input(input))
		var speed: float = obj.movement_speed
		if Input.is_action_pressed("run"):
			speed *= obj.sprint_multiplier
			obj.is_running(true)
		else:
			obj.is_running(false)
		obj.velocity.x = speed * input.x
		obj.velocity.z = speed * input.y
		if obj.is_on_floor():
			change_state(fsm.states.run)
		return true
	else:
		obj.stop_horizontal()
		obj.is_running(false)
	return false

#Control jumping
#Return true if jumping
func control_jump() -> bool:
	if not Input.is_action_just_pressed("jump"):
		return false
	if obj.can_coyote():
		obj.ground_jump()
		change_state(fsm.states.jump)
		return true
	if obj.can_air_jump():
		obj.air_jump()
		change_state(fsm.states.jump)
		return true
	return false
