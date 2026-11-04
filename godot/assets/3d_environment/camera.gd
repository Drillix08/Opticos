extends Camera3D

const MOVE_SPEED = 2.5
const ZOOM_SPEED = 4.0
const FLY_SPEED = 2.0
const H_LOOK_SPEED = 1.0
const V_LOOK_SPEED = 0.5
const V_LOOK_MAX = deg_to_rad(90.0)
const V_LOOK_MIN = deg_to_rad(-90.0)
const ORBIT_SPEED = deg_to_rad(30.0)
const TWO_PI = deg_to_rad(360.0)
const MIN_ORBIT_RADIUS = 2.0
const MAX_ORBIT_RADIUS = 16.0
const MOUSE_SENS_FREE_FLY = 0.5
const MOUSE_SENS_ORBIT = 0.6

enum {
	MODE_FREE_FLY = 0,
	MODE_ORBIT = 1,
}

var camera_mode = MODE_ORBIT
var orbit_angle = deg_to_rad(45.0)
var orbit_tilt = deg_to_rad(-10.0)
var orbit_radius = 10.0
var last_mouse_coords = Vector2(0.0, 0.0)
var mouse_coords = Vector2(0.0, 0.0)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
	mouse_coords = get_viewport().get_mouse_position()

	if Input.is_action_just_pressed("ToggleFlightMode"):
		match camera_mode:
			MODE_FREE_FLY:
				camera_mode = MODE_ORBIT
			MODE_ORBIT:
				camera_mode = MODE_FREE_FLY

	match camera_mode:
		MODE_FREE_FLY:
			camera_free_fly(delta)
		MODE_ORBIT:
			camera_orbit(delta)

	last_mouse_coords = mouse_coords


func camera_free_fly(delta: float):
	$Label.text = "Mode: Free Fly"

	if Input.is_action_pressed("MoveForward"):
		position.z -= cos(rotation.y) * MOVE_SPEED * delta
		position.x -= sin(rotation.y) * MOVE_SPEED * delta
	if Input.is_action_pressed("MoveBackward"):
		position.z += cos(rotation.y) * MOVE_SPEED * delta
		position.x += sin(rotation.y) * MOVE_SPEED * delta
	if Input.is_action_pressed("MoveLeft"):
		position.z += sin(rotation.y) * MOVE_SPEED * delta
		position.x -= cos(rotation.y) * MOVE_SPEED * delta
	if Input.is_action_pressed("MoveRight"):
		position.z -= sin(rotation.y) * MOVE_SPEED * delta
		position.x += cos(rotation.y) * MOVE_SPEED * delta
	if Input.is_action_pressed("FlyUp"):
		position.y += FLY_SPEED * delta
	if Input.is_action_pressed("FlyDown"):
		position.y -= FLY_SPEED * delta

	if Input.is_action_pressed("LookLeft"):
		rotation.y += H_LOOK_SPEED * delta
	if Input.is_action_pressed("LookRight"):
		rotation.y -= H_LOOK_SPEED * delta
	if Input.is_action_pressed("LookUp"):
		rotation.x = min(V_LOOK_MAX, rotation.x + V_LOOK_SPEED * delta)
	if Input.is_action_pressed("LookDown"):
		rotation.x = max(V_LOOK_MIN, rotation.x - V_LOOK_SPEED * delta)

	if Input.is_action_pressed("LeftMouseButton"):
		var x_diff = mouse_coords.x - last_mouse_coords.x
		var y_diff = mouse_coords.y - last_mouse_coords.y
		rotation.y -= x_diff * ORBIT_SPEED * MOUSE_SENS_FREE_FLY * delta
		if rotation.y < 0.0:
			rotation.y += TWO_PI
		while rotation.y >= TWO_PI:
			rotation.y -= TWO_PI
		rotation.x -= y_diff * V_LOOK_SPEED * MOUSE_SENS_FREE_FLY * delta
		rotation.x = min(max(rotation.x, V_LOOK_MIN), V_LOOK_MAX)


func camera_orbit(delta: float):
	$Label.text = "Mode: Orbit"

	if Input.is_action_pressed("FlyUp"):
		orbit_radius = max(MIN_ORBIT_RADIUS, orbit_radius - ZOOM_SPEED * delta)
	if Input.is_action_pressed("FlyDown"):
		orbit_radius = min(MAX_ORBIT_RADIUS, orbit_radius + ZOOM_SPEED * delta)

	if Input.is_action_pressed("LookLeft"):
		orbit_angle -= ORBIT_SPEED * delta
		if orbit_angle < 0.0:
			orbit_angle += TWO_PI
	if Input.is_action_pressed("LookRight"):
		orbit_angle += ORBIT_SPEED * delta
		if orbit_angle >= TWO_PI:
			orbit_angle -= TWO_PI
	if Input.is_action_pressed("LookUp"):
		orbit_tilt = max(V_LOOK_MIN, orbit_tilt - V_LOOK_SPEED * delta)
	if Input.is_action_pressed("LookDown"):
		orbit_tilt = min(V_LOOK_MAX, orbit_tilt + V_LOOK_SPEED * delta)

	if Input.is_action_pressed("LeftMouseButton"):
		var x_diff = mouse_coords.x - last_mouse_coords.x
		var y_diff = mouse_coords.y - last_mouse_coords.y
		orbit_angle -= x_diff * ORBIT_SPEED * MOUSE_SENS_ORBIT * delta
		if orbit_angle < 0.0:
			orbit_angle += TWO_PI
		while orbit_angle >= TWO_PI:
			orbit_angle -= TWO_PI
		orbit_tilt -= y_diff * V_LOOK_SPEED * MOUSE_SENS_ORBIT * delta
		orbit_tilt = min(max(orbit_tilt, V_LOOK_MIN), V_LOOK_MAX)

	position.y = -orbit_radius * sin(orbit_tilt)
	rotation.x = orbit_tilt
	rotation.y = orbit_angle
	position.x = orbit_radius * sin(orbit_angle) * cos(orbit_tilt)
	position.z = orbit_radius * cos(orbit_angle) * cos(orbit_tilt)
