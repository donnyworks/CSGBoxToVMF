extends CSGBox3D
class_name ValveBrushEntity

@export var OriginEntity : Node3D ## Point defining the origin of this object
@export var classname := "func_detail"
@export var flags := 1 ## Brush flags.
@export var start_disabled := false ## Tells if a brush should start out inactive
@export var connections : Array[ValveConnection] = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
