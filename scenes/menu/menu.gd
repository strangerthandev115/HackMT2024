extends Node2D

signal start_pressed

func _on_start_game_pressed():
	# Emit start signal
	SceneManager.button_chime()
	emit_signal("start_pressed")
	

func _on_quit_game_pressed():
	# Fade out before closing
	SceneManager.button_chime()
	SceneManager.fade_out()
	await SceneManager.faded_out
	# Close the game
	get_tree().quit()

func _on_credits_view_pressed():
	# Fade out before closing
	SceneManager.button_chime()
	SceneManager.fade_out()
	await SceneManager.faded_out
	# Make credits appear and menu disappear
	$TitleNameMap.visible = false
	$CreditsBack.visible = true
	$CreditsBack/CreditsCanvas.visible = true
	SceneManager.fade_in()


func _on_credits_back_pressed():
	# Fade out before closing
	SceneManager.button_chime()
	SceneManager.fade_out()
	await SceneManager.faded_out
	# Make credits disappear and menu appear
	$TitleNameMap.visible = true
	$CreditsBack.visible = false
	$CreditsBack/CreditsCanvas.visible = false
	SceneManager.fade_in()
