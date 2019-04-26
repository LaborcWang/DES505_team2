extends Object

var velocity = 0.0
var time = 0.0
var jump = false
var freefall = false

const GRAVITY = -9.8
const VELOCITY_LIMIT = -10
		
func is_jumping():
	return jump

func is_in_freefall():
	return freefall

func start_jump(var jump_velocity):
	if(!jump && !freefall) :
		velocity = jump_velocity
		jump = true

func reset():
	if(time < 0.5):
		return
	freefall = false
	jump = false
	velocity = 0.0
	time = 0.0

func tick(var delta):
	time += delta
	velocity += GRAVITY*delta

	if velocity < VELOCITY_LIMIT:
		velocity = VELOCITY_LIMIT
		freefall = true
		jump = false

func get_displacement(var delta):
	return velocity * delta
