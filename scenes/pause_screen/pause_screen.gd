extends CanvasLayer

signal return_title
var pause = false

func _ready():
	# Hide pause menu once in tree
	hide()
	
func _input(event):
	# Check if esc is pressed and swap paused state
	if event.is_action_pressed("pause"):
		if pause == false:
			get_tree().paused = true
			show()
		elif pause == true:
			hide()
			get_tree().paused = false
	pause = !pause

func _on_full_choice_toggled(toggled_on):
	# Shift screen between windowed and fullscreen
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)


func _on_return_title_pressed():
	# Hide the pause menu
	hide()
	# Emit signal to return to title screen
	emit_signal("return_title")


func _on_return_desktop_pressed():
	# Hide the pause menu
	hide()
	# Fade out before closing
	SceneManager.fade_out()
	await SceneManager.faded_out
	# Close the game
	get_tree().quit()


func _on_resume_game_pressed():
	get_tree().paused = false
	hide()
