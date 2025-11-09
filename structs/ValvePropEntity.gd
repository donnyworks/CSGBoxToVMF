@tool
extends MeshInstance3D
class_name ValvePropEntity

@export var model = "error.mdl"

var classname = "prop_dynamic"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mesh = load("res://editor/missing.mesh")
	var object = load("res://enginemodels/" + model.replace(".mdl",".obj"))
	if object != null:
		rotation_degrees = Vector3(90,0,0)
		scale = Vector3(1.0/50,1.0/50,1.0/50)
		mesh = object
	#add_child(mesh)
	pass # Replace with function body.
