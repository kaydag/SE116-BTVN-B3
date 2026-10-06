extends PlayerState

func _enter() -> void:
	obj.change_animation("run")
	
	pass

func _update(delta: float):
	if control_jump():
		return
	if not control_moving():
		change_state(fsm.states.idle)
	if not obj.is_on_floor():
		change_state(fsm.states.fall)
	pass
