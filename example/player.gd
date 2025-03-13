extends Control

func _on_PlayPause_pressed() -> void:
	if not $Gopotify.player:
		await $Gopotify.update_player_state()
		
	var playing = $Gopotify.player.is_playing
	if playing:
		$Gopotify.player.pause()
		$CenterContainer/HBoxContainer/PlayPause.text = "|>"
	else:
		$Gopotify.player.play()
		$CenterContainer/HBoxContainer/PlayPause.text = "||"

func _on_Next_pressed() -> void:
	if not $Gopotify.player:
		await $Gopotify.update_player_state()
	$Gopotify.player.skip()

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

func track_play(track: GopotifyTrack) -> void:
	await track.play()


func _on_update_queue_pressed() -> void:
	if not $Gopotify.player:
		await $Gopotify.update_player_state()
	for old_label in $Queue/VBoxContainer.get_children():
		if old_label is Label: old_label.queue_free()
	var queue = await $Gopotify.player.update_queue()
	for track in queue:
		var label = Label.new()
		label.text = str(track)
		label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		label.clip_text = true
		$Queue/VBoxContainer.add_child(label)
