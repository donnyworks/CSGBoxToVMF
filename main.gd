extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	CSGBoxToVMF.BuildVMF("output.vmf",self)
	await get_tree().create_timer(0.25).timeout
	get_tree().quit()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
