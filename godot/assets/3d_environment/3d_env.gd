extends Node

@export var linepixel: PackedScene

const LINEDRAW_STARTPOS = Vector3(8.0, 8.0, 8.0)
const LINEDRAW_ENDPOS = Vector3(-8.0, -8.0, -8.0)
const LINEDRAW_MOVEMENT = Vector3(-0.2, -0.2, -0.2)


func spawn_linepixel():
	var lp = linepixel.instantiate()
	lp.init($LineDrawer.position)
	add_child(lp)


func vec3_not_equal(v1: Vector3, v2: Vector3):
	const FP_MARGIN = 0.001
	return abs(v1.x - v2.x) > FP_MARGIN \
			or abs(v1.y - v2.y) > FP_MARGIN \
			or abs(v1.z - v2.z) > FP_MARGIN


# Called when the node enters the scene tree for the first time.
func _ready():
	$LineDrawer.position = LINEDRAW_STARTPOS
	spawn_linepixel()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if vec3_not_equal($LineDrawer.position, LINEDRAW_ENDPOS):
		$LineDrawer.position += LINEDRAW_MOVEMENT
		spawn_linepixel()
