extends RefCounted

class_name GopotifyPlayer

var _client: GopotifyClient

var device: GopotifyDevice

var repeat_state: StringName
var shuffle_state: bool
# skip context, i see no use for this with item existing?
var timestamp: int
var progress_ms: int
var is_playing: bool
var item: GopotifyTrack # TODO: This can also be an EpisodeObject
var currently_playing_type: StringName # TODO: this will only ever be 'track' or 'unknown' until episode support is added
var actions: Dictionary

func _init(playback_state: Dictionary, client: GopotifyClient):
	device = GopotifyDevice.new(playback_state["device"])
	repeat_state = playback_state["repeat_state"]
	shuffle_state = playback_state["shuffle_state"]
	timestamp = playback_state["timestamp"]
	progress_ms = playback_state["progress_ms"]
	is_playing = playback_state["is_playing"]
	currently_playing_type = playback_state["currently_playing_type"]
	actions = playback_state["actions"]

	# Handle item (track or null for now)
	item = GopotifyTrack.new(playback_state["item"], self._client) if playback_state.has("item") else null
