extends PlayerState

func _enter() -> void:
	obj.change_animation("fall")
	obj.velocity.y = minf(obj.velocity.y, 0.0)
	obj.max_fall_speed = obj.wall_slide_speed
	obj.air_jump_count = obj.jump_count

func _exit() -> void:
	obj.max_fall_speed = INF

func _update(_delta: float) -> void:
	control_moving()
	if obj.is_on_floor():
		change_state(fsm.states.idle)
		return
	if not obj.is_on_wall():
		change_state(fsm.states.fall)
		return
	if Input.is_action_just_pressed("jump"):  
		obj.wall_jump()
		change_state(fsm.states.jump)
		return
