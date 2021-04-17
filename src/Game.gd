extends Node2D

export (String, FILE, '*.tscn') var main: String
export (String, FILE, '*.tscn') var restroom: String

onready var _main: Node = load(main).instance()
onready var _restroom: Node = load(restroom).instance()

func _ready():
	_load_main()


func _load_main() -> void:
	add_child(_main)


func load_restroom() -> void:
	remove_child(_main)
	_main.queue_free()
	add_child(_restroom)
