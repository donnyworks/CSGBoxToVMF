extends Node
class_name ValveConnection

@export var connection = "Trigger" ## On + connection_name = OnTrigger

@export var connected : String ## name of entity being connected to

@export var callable = "Disable" ## Fired output on connected entity

@export var arguments = "" ## Keep none if none

@export var delay = 0.0 ## Delay between connection occuring and output being fired

@export var max_amount = -1 ## Amount of max fires (-1 = infinite)
