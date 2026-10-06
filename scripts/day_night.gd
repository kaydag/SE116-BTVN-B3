extends DirectionalLight3D

@export var day_length := 60.0     
@export var max_energy := 1.2      
@export var night_energy := 0.1    

var gradient := Gradient.new()
var t := 0.0                        

func _ready():
	gradient.offsets = PackedFloat32Array([0.0, 0.25, 0.5, 0.6, 0.9, 1.0])
	gradient.colors = PackedColorArray([Color("ffb070"), Color("fff4e0"), Color("ff8a50"), Color("2a3a66"),Color("2a3a66"), Color("ffb070"),])

func _process(delta):
	t = fmod(t + delta / day_length, 1.0)
	rotation_degrees.x = -t * 360.0                      
	light_color = gradient.sample(t)
	var sun := clampf(sin(t * TAU), 0.0, 1.0)          
	light_energy = lerpf(night_energy, max_energy, sun)
