extends Sprite2D

@onready var camera = $Camera2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position = owner.find_parent("world").find_child("Player").position
