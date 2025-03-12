extends RefCounted

class_name GopotifyArtist

var uri: String
var type: String
var href: String
var id: String
var name: String

func _init(artist_object: Dictionary) -> void:
	uri = artist_object["uri"]
	type = artist_object["type"]
	href = artist_object["href"]
	id = artist_object["id"]
	name = artist_object["name"]


func _to_string() -> String:
	return self.name
