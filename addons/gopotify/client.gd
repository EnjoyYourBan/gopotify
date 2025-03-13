extends HTTPRequest
class_name GopotifyClient

const CREDENTIALS_FILE = "gopotify_credentials.json"

const AUTH_URL := "https://accounts.spotify.com/"
const SPOTIFY_BASE_URL := "https://api.spotify.com/v1/"
const SCOPES = [
	"user-modify-playback-state",
	"user-read-playback-state"
]

@export var client_id := ""
@export var client_secret := ""
@export var port := 8889

var credentials: GopotifyCredentials

var server: GopotifyAuthServer

var player: GopotifyPlayer

class GopotifyResponse:
	var status_code: int
	var headers: PackedStringArray
	var body: PackedByteArray

	func _init(_status_code, _headers, _body):
		self.status_code = _status_code
		self.headers = _headers
		self.body = _body

	func _to_string():
		return "[{0}]\n{1}".format([self.status_code, self.body.get_string_from_ascii()])

func _ready() -> void:
	self.credentials = self.read_credentials()

func read_credentials() -> GopotifyCredentials:
	if FileAccess.file_exists("user://" + CREDENTIALS_FILE):
		var file = FileAccess.open("user://" + CREDENTIALS_FILE, FileAccess.READ)
		
		var parsed = JSON.parse_string(file.get_as_text())
		file.close()
		print(parsed)
		if not 'error' in parsed:
			return GopotifyCredentials.new(
				parsed["access_token"],
				parsed["refresh_token"],
				parsed["expires_in"],
				parsed["issued_at"]
			)

	return null

func write_credentials(credentials: GopotifyCredentials) -> void:
	var file = FileAccess.open("user://" + CREDENTIALS_FILE, FileAccess.WRITE)
	file.store_string(JSON.stringify({
		"access_token": credentials.access_token,
		"refresh_token": credentials.refresh_token,
		"expires_in": credentials.expires_in,
		"issued_at": credentials.issued_at
	}))
	file.close()

func _start_auth_server() -> void:
	self.server = GopotifyAuthServer.new(Callable(self, "request_new_credentials"))
	add_child(self.server)

func _stop_auth_server() -> void:
	self.server.queue_free()
	self.server = null

func request_new_credentials(code) -> bool:
	var url := AUTH_URL + "api/token/"
	var data := self._build_query_params({
		"grant_type": "authorization_code",
		"code": code,
		"redirect_uri": self._get_redirect_uri()
	})
	var headers := [
		"Content-Type: application/x-www-form-urlencoded",
		"Authorization: Basic " + self._build_basic_authorization_header_token(),
		"Content-Length: " + str(len(data))
	]

	var result: Array = await self.simple_request(HTTPClient.METHOD_POST, url, headers, data)
	if result[1] == HTTPClient.RESPONSE_OK:
		var json_result = await JSON.parse_string(result[3].get_string_from_ascii())
		var credentials = GopotifyCredentials.new(
			json_result["access_token"],
			json_result["refresh_token"],
			int(json_result["expires_in"]),
			Time.get_unix_time_from_system()
		)
		self.set_credentials(credentials)
		return true

	return false

func request_user_authorization() -> void:
	self._start_auth_server()
	var url = AUTH_URL + "authorize/"
	var result = await self.simple_request(
			HTTPClient.METHOD_GET,
			url,
			[],
			"",
			{
				"client_id": self.client_id,
				"response_type": "code",
				"redirect_uri": self._get_redirect_uri(),
				"scope": ",".join(SCOPES)
			}
		)
	var code_url = result[2][2].substr(10)
	OS.shell_open(code_url)

func set_credentials(credentials: GopotifyCredentials) -> void:
	self.credentials = credentials
	self.write_credentials(credentials)
	self._stop_auth_server()

func _get_redirect_uri() -> String:
	return "http://localhost:{port}{endpoint}".format({"port": self.port, "endpoint": GopotifyAuthServer.AUTH_ENDPOINT})

func _build_basic_authorization_header_token() -> String:
	return Marshalls.utf8_to_base64(client_id+":"+client_secret)

func _build_query_params(params: Dictionary = {}) -> String:
	var param_array := PackedStringArray()

	for key in params:
		param_array.append(str(key) + "=" + str(params[key]))

	return "&".join(param_array)

func _spotify_request(path: String, http_method: int, body: String = "", retries: int = 1) -> GopotifyResponse:
	if retries < 0:
		return GopotifyResponse.new(500, [], [])

	if not self.credentials:
		self.request_user_authorization()
		await self.server.credentials_received
		return await self._spotify_request(path, http_method, body, retries-1)

	var headers := [
		"Authorization: Bearer " + self.credentials.access_token,
		"Content-Type: application/json",
		"Content-Length: " + str(len(body))
	]
	var url := SPOTIFY_BASE_URL + path

	var raw_response: Array = await self.simple_request(http_method, url, headers, body)
	var response := GopotifyResponse.new(raw_response[1], raw_response[2], raw_response[3])
	if self.credentials.is_expired() or response.status_code == 401:
		self.request_user_authorization()
		await self.server.credentials_received
		return await self._spotify_request(path, http_method, body, retries-1)

	return response

func simple_request(method: int, url: String, headers: Array = [], body: String = "", params: Dictionary = {}) -> Array:
	var query_params: String = "" if params.size() < 1 else "?" + self._build_query_params(params)

	self.request(
		url + query_params,
		headers,
		method,
		body
	)

	return await self.request_completed
	
func search(query: String, types: Array, offset: int = 0, limit: int = -1) -> GopotifySearchResult:
	var params = PackedStringArray()
	
	# Add required query parameters
	params.append("q=" + query.uri_encode())
	params.append("type=" + ",".join(types).uri_encode())

	# Add optional parameters only if they are valid
	if limit > 0:
		params.append("limit=" + str(limit))
	if offset > 0:
		params.append("offset=" + str(offset))

	# Construct the full URL
	var url = "search?" + "&".join(params)

	# Make the request
	var result = await self._spotify_request(url, HTTPClient.METHOD_GET)
	
	# Parse and return the response
	return GopotifySearchResult.new(JSON.parse_string(result.body.get_string_from_utf8()), self)

	
func play(tracks=[]) -> GopotifyResponse:
	var body = ""
	if tracks:
		var json_body = {"uris": tracks}
		body = JSON.stringify(json_body)

	return await self._spotify_request("me/player/play", HTTPClient.METHOD_PUT, body)

func pause() -> GopotifyResponse:
	return await self._spotify_request("me/player/pause", HTTPClient.METHOD_PUT)

func next() -> GopotifyResponse:
	return await self._spotify_request("me/player/next", HTTPClient.METHOD_POST)

func previous() -> GopotifyResponse:
	return await self._spotify_request("me/player/previous", HTTPClient.METHOD_POST)

#TODO: Fix? returns 404 not found [???] see @ https://developer.spotify.com/documentation/web-api/reference/add-to-queue
func queue(track: String, device_id: String = &"") -> GopotifyResponse:
	var params = PackedStringArray()

	params.append("?uri=" + track.uri_encode())

	if device_id != &"":
		params.append("&device_id=" + device_id.uri_encode())

	var url = "/me/player/queue" + "".join(params)
	
	return await self._spotify_request(url, HTTPClient.METHOD_POST)
	
func update_player_state() -> GopotifyPlayer:
	var response = await (self._spotify_request("me/player", HTTPClient.METHOD_GET))
	var parsed_json = JSON.parse_string(response.body.get_string_from_utf8())
	if not parsed_json or 'error' in parsed_json: # no playback state found
		return null
	self.player = GopotifyPlayer.new(parsed_json, self)
	return self.player
