extends PlayerState

func _enter() -> void:
	obj.change_animation("jump")
	pass

func _update(_delta: float):
	control_moving()
	if obj.velocity.y < 0:
		change_state(fsm.states.fall)
		return
	if obj.wall_jump_lock <= 0.0:
		control_moving()
