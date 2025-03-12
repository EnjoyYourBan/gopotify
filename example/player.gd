extends Control

func _on_PlayPause_pressed() -> void:
	var playing = (await $Gopotify.get_player_state()).is_playing
	if playing:
		$Gopotify.pause()
		$CenterContainer/HBoxContainer/PlayPause.text = "|>"
	else:
		$Gopotify.play()
		$CenterContainer/HBoxContainer/PlayPause.text = "||"

func _on_Next_pressed() -> void:
	$Gopotify.next()

func _on_Previous_pressed() -> void:
	$Gopotify.previous()


func _on_search_pressed() -> void:
	var query = $CenterContainer/HBoxContainer/SearchBox.text
	if len(query) < 3: return
	
	var search_result = await $Gopotify.search(query, ["track"])
	
	for child in $SearchResult/VBoxContainer.get_children():
		child.queue_free()
		
	for track in search_result.tracks:
		var button = Button.new()
		button.text = str(track)
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.connect("pressed", track_play.bind(track))
		$SearchResult/VBoxContainer.add_child(button)

func track_play(track) -> void:
	print("Now playing song: %s" % track)
	track.play()
