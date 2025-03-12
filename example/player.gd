extends Control


func _on_PlayPause_pressed():
	var playing = (await $Gopotify.get_player_state()).is_playing
	if playing:
		$Gopotify.pause()
		$CenterContainer/HBoxContainer/PlayPause.text = "|>"
	else:
		$Gopotify.play()
		$CenterContainer/HBoxContainer/PlayPause.text = "||"

func _on_Next_pressed():
	$Gopotify.next()

func _on_Previous_pressed():
	$Gopotify.previous()
