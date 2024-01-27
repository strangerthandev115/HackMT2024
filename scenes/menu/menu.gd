extends Node2D

signal start_pressed

func _on_start_game_pressed():
	emit_signal("start_pressed")
	

func _on_quit_game_pressed():
	SceneManager.fade_out()
	await SceneManager.faded_out
	# Close the game
	get_tree().quit()
