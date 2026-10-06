extends BaseCharacter

func _ready() -> void:
	fsm = FSM.new(self, $State, $State/Idle, true)
	super._ready()
