extends RefCounted

class_name GopotifySearchResult
var _client: GopotifyClient

var tracks: Array[GopotifyTrack]

var _href: String
var _next: String
var _previous: String

var _offset: int
var _total: int
var _limit: int

func _init(search_response: Dictionary, client: GopotifyClient) -> void:
	if 'tracks' in search_response:
		search_response = search_response.tracks
		self._href = search_response.href
		self._limit = search_response.limit
		self._next = search_response["next"] if search_response["next"] != null else ""
		self._offset = int(search_response.offset)
		self._previous = search_response["previous"] if search_response["previous"] != null else ""
		for track in search_response.items:
			tracks.append(GopotifyTrack.new(track, client))
