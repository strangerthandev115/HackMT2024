extends SubViewport

@onready var camera = $Camera2D
@export var Tilemap : TileMap

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	camera.position.x = find_parent("world").find_child("Player").position.x
