@tool
extends Node3D
class_name ValvePointEntity

@export var classname = "info_player_start"
@export var parameters = {} ## Key-value pairs. Key and value are strings, just as they are in the VMF.
@export var connections : Array[ValveConnection] = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var object = load("res://editor/" + classname + ".obj")
	if object != null:
		var mesh = MeshInstance3D.new()
		mesh.mesh = object
		mesh.scale = Vector3(1.0/64,1.0/64,1.0/64)
		add_child(mesh)
	else:
		var spr = Sprite3D.new()
		spr.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		spr.texture = load("res://editor/obsolete.png")
		var object2 = load("res://editor/" + classname + ".png")
		if object2 != null:
			spr.texture = object2
		add_child(spr)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
