class_name TwitchAPI

extends Node

signal token_received(TwitchChannel)

const TWITCH_REDIRECT_HOST = "http://localhost:"

const USELESS_UUID = "53125396-3e32-4fad-8f7e-36475724168b-a8fe83ab-3373-4a6a-8967-2532eafe407f-41483db3-f011-4a23-80da-9a340672692a-e755c6d4-c546-43ce-b722-b5a799561b4e-5ba1697d-79b2-4d5d-96c3-f0d91f13f583-f08f18f9-bd56-4a0f-a597-96f90108cd85-14449d50-6cc9-450f-8119-ff4c525e31db-e41a6912-92a0-48b6-b6d3-845c21bea7eb-7dfd7948-2976-42cf-9cca-b23ae5854813-107224eb-81ea-46dd-9bf5-9ebbfcfc45dc/"

const RESPONSE_TYPE = 'token'

const TWITCH_VALIDATE_URL = "https://id.twitch.tv/oauth2/validate"
const TWITCH_BAN_URL = "https://api.twitch.tv/helix/moderation/bans"
const TWITCH_OAUTH_URL = "https://id.twitch.tv/oauth2/authorize"
const TWITCH_VIP_URL = "https://api.twitch.tv/helix/channels/vips"
const TWITCH_SETTINGS_URL = "https://api.twitch.tv/helix/chat/settings"
const TWITCH_CHATTERS_URL = "https://api.twitch.tv/helix/chat/chatters"

var free_port:int = 8090

var _scopes: PackedStringArray
var _client_id: String

var _user: TwitchChannel

func initiate_twitch_auth():
	_scopes = TwitchSettings.get_setting(TwitchSettings.settings.scopes)
	_client_id = TwitchSettings.get_setting(TwitchSettings.settings.client_id)
	var auth_server = TwitchAuthServer.new()
	add_child(auth_server)
	auth_server.OnTokenReceived.connect(_on_auth_server_on_token_received)
	auth_server.stop_server()
	auth_server.start_server(8090)

	var redirect_uri = TWITCH_REDIRECT_HOST + str(free_port) + "/" + USELESS_UUID
	var scopes_string = "+".join(_scopes)
	var url = "client_id=" + _client_id + "&redirect_uri=" + redirect_uri + "&response_type=" + RESPONSE_TYPE + "&scope=" + scopes_string

	OS.shell_open(TWITCH_OAUTH_URL + "?" + url)

func _on_auth_server_on_token_received(token) -> void:
	var validated_user = await validate_token_and_get_user_id(token)
	if !(validated_user):
		print('Invalid token')
		_user = null
		return
	_user = validated_user
	token_received.emit(_user)

func request_fail(status:int, error: VSTError, on_fail: Callable):
	if status == 401 or status == 403:
		#Unauthorized? No mi ciela
		initiate_twitch_auth()
		# TODO: should chain the request?
	else:
		push_warning(error)
		on_fail.call()

func validate_token_and_get_user_id(token: String):
	var client = HTTPRequest.new()
	add_child(client)
	client.request(TWITCH_VALIDATE_URL, [
		'Authorization: OAuth ' + token
	])
	var result = await client.request_completed
	var status = result[1]
	if status != 200:
		return null
	var data = (result[3] as PackedByteArray).get_string_from_utf8()
	var data_parsed = JSON.parse_string(data)
	var user = TwitchChannel.new()
	user.id = data_parsed['user_id']
	user.login = data_parsed['login']
	user.token = token
	client.queue_free()
	return user

func timeout_user(user_to_ban_id: String, duration: int = 1, reason: String = '', on_success: Callable = Callable(), on_fail: Callable = Callable()):
	if !_user:
		return

	var timeout_duration = max(duration, 1)
	var body = {
		data = {
			user_id = user_to_ban_id,
			duration = timeout_duration,
			reason = reason
		},
	}

	Network_Call.new().to(TWITCH_BAN_URL).\
	add_all_get_params({'broadcaster_id': _user.id,
		'moderator_id': _user.id}).\
	with(body).\
	verb(HTTPClient.METHOD_POST).\
	add_all_headers({'Client-Id: ' : _client_id,
		'Authorization': 'Bearer ' + _user.token,
		'Content-Type': 'application/json'}).\
	set_on_call_fail(request_fail.bind(on_fail)).\
	set_on_call_success(on_success).\
	launch_request(self)

func add_vip(user_to_vip_id: String, on_success: Callable = Callable(), on_fail: Callable = Callable()):
	if !_user:
		return

	Network_Call.new().to(TWITCH_VIP_URL).\
	add_all_get_params({'broadcaster_id': _user.id,
		'user_id': user_to_vip_id}).\
	verb(HTTPClient.METHOD_POST).\
	add_all_headers({'Client-Id: ' : _client_id,
		'Authorization': 'Bearer ' + _user.token,
		'Content-Type': 'application/json'}).\
	set_on_call_fail(request_fail.bind(on_fail)).\
	set_on_call_success(on_success).\
	launch_request(self)

func remove_vip(user_to_remove_vip_id: String, on_success: Callable = Callable(), on_fail: Callable = Callable()):
	if !_user:
		return

	Network_Call.new().to(TWITCH_VIP_URL).\
	add_all_get_params({'broadcaster_id': _user.id,
		'user_id': user_to_remove_vip_id}).\
	verb(HTTPClient.METHOD_DELETE).\
	add_all_headers({'Client-Id: ' : _client_id,
		'Authorization': 'Bearer ' + _user.token,
		'Content-Type': 'application/json'}).\
	set_on_call_fail(request_fail.bind(on_fail)).\
	set_on_call_success(on_success).\
	launch_request(self)
