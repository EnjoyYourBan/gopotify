extends RefCounted

class_name GopotifyTrack
var _client: GopotifyClient

var album: GopotifyAlbum
var artists: Array[GopotifyArtist]
var disc_number: int
var explicit: bool
var external_ids: Dictionary
var external_urls: Dictionary
var href: String
var id: String
var is_local: bool
var is_playable: bool
var name: String
var popularity: int
var preview_url: String
var track_number: int
var type: StringName
var uri: String

# TODO: Artist object
func _init(track_object: Dictionary, client: GopotifyClient) -> void:
	self._client = client
	
	#album = GopotifyAlbum.new(track_object["album"]) 
	for artist in track_object["artists"]:
		artists.append(GopotifyArtist.new(artist))
	disc_number = track_object["disc_number"]
	explicit = track_object["explicit"]
	external_ids = track_object["external_ids"]
	external_urls = track_object["external_urls"]
	href = track_object["href"]
	id = track_object["id"]
	is_local = track_object["is_local"]
	
	if track_object.get("is_playable") == null:
		is_playable = true
	else:
		is_playable = track_object["is_playable"]
		
	name = track_object["name"]
	popularity = track_object["popularity"]
	if track_object.has("preview_url") and preview_url != "":
		preview_url = track_object["preview_url"]
	
	track_number = track_object["track_number"]
	type = StringName(track_object["type"])
	uri = track_object["uri"]

	# TODO: Handle full artist object if needed

func _to_string() -> String:
	return "[%s] %s" % [artists[0].name, name]

func queue():
	await _client.queue(uri)
	
func play():
	await _client.play([uri])
