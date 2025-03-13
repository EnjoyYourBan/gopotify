extends RefCounted

class_name GopotifyPlayer

var queue: Array[GopotifyTrack] = []
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
	self._client = client

func skip():
	if len(queue) > 0:
		self.item = self.queue.pop_at(0)
	self._client.next()
	
func play():
	self.is_playing = true
	self._client.play([], device.id)
	
func pause():
	self.is_playing = false
	self._client.pause(device.id)

# track, context, off
func repeat(state: String = "track"):
	# if they repeat, and its already on repeat, just turn it off
	if state == repeat_state:
		state = "off"
		
	self.repeat_state = state
	var url = "me/player/repeat?state={0}&device_id={1}".format([state, device.id])
	await self._client._spotify_request(url, HTTPClient.METHOD_PUT)

func set_volume(volume: int):
	
	var url = "me/player/volume?volume_percent={0}&device_id={1}".format([volume, device.id])
	await self._client._spotify_request(url, HTTPClient.METHOD_PUT)
	self.device.volume_percent = volume

func toggle_shuffle(state: bool = not self.shuffle_state):
	self.shuffle_state = state
	var url = "me/player/shuffle?state={0}&device_id={1}".format([state, device.id])
	await self._client._spotify_request(url, HTTPClient.METHOD_PUT)

func seek(position_ms: int):
	self.progress_ms = position_ms
	var url = "me/player/seek?position_ms={0}&device_id={1}".format([position_ms, device.id])
	await self._client._spotify_request(url, HTTPClient.METHOD_PUT)

func update_queue() -> Array[GopotifyTrack]:
	var new_queue: Array[GopotifyTrack] = []
	
	var request = await self._client._spotify_request("me/player/queue", HTTPClient.METHOD_GET)
	var object = JSON.parse_string(request.body.get_string_from_utf8())
	
	if not object:
		self.queue.clear()
		return self.queue
		
	for track in object["queue"]:
		new_queue.append(GopotifyTrack.new(track, _client))
	if 'now_playing' in object:
		self.item = GopotifyTrack.new(object["now_playing"], _client)
		
	self.queue = new_queue
	
	return self.queue
