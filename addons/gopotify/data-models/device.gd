extends RefCounted

class_name GopotifyDevice

var id: String
var is_active: bool
var is_private_session: bool
var is_restricted: bool
var _name: String
var type: String
var volume_percent: int # Nullable
var supports_volume: bool


func _init(device_object: Dictionary):
	id = device_object["id"]
	is_active = device_object["is_active"]
	is_private_session = device_object["is_private_session"]
	is_restricted = device_object["is_restricted"]
	_name = device_object["name"]
	type = device_object["type"]
	supports_volume = device_object["supports_volume"]

	volume_percent = device_object["volume_percent"] if device_object["volume_percent"] != null else -1
