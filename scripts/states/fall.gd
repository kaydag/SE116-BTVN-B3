extends PlayerState

func _enter() -> void:
	obj.change_animation("fall")

func _update(_delta: float) -> void:
	var is_moving: bool = control_moving()
	if obj.is_on_wall() and not obj.is_on_floor():
		change_state(fsm.states.cling)
		return
	if obj.is_on_floor() and not is_moving:
		change_state(fsm.states.idle)
		return
	if control_jump():
		return
