extends Control

signal faded_in
signal faded_out

# Wrapper function for performing fade in animation
func fade_in():
	$ScreenFader/FadePlayer.play("fade_in")
	await $ScreenFader/FadePlayer.animation_finished
	emit_signal("faded_in")
	
# Wrapper function for performing fade out animation
func fade_out():
	$ScreenFader/FadePlayer.play("fade_out")
	await $ScreenFader/FadePlayer.animation_finished
	emit_signal("faded_out")
	
func _ready():
	# Load the main menu scene
	var main_menu=preload("res://scenes/menu/menu.tscn").instantiate()
	add_child(main_menu)
	# Fade into main menu
	fade_in()
	# Connect a signal so that when start game is pressed, the game begins
	main_menu.connect('start_pressed',transition_to_level_one)

func transition_to_level_one():
	# Fade out of main menu
	fade_out()
	await faded_out
	# Remove the main menu
	get_node("Menu").queue_free()
	# Load in level one
	var world=preload("res://scenes/world/world.tscn").instantiate()
	add_child(world)
	# Load in pause menu
	var pause=preload("res://scenes/pause_screen/pause_screen.tscn").instantiate()
	add_child(pause)
	# Fade into level one
	fade_in()
	await faded_in
