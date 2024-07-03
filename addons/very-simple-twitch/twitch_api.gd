class_name TwitchAPI

extends Node

signal token_received(TwitchChannel)


const RESPONSE_TYPE = 'token'

const TWITCH_VALIDATE_URL = "https://id.twitch.tv/oauth2/validate"
const TWITCH_BAN_URL = "https://api.twitch.tv/helix/moderation/bans"
const TWITCH_OAUTH_URL = "https://id.twitch.tv/oauth2/authorize"
const TWITCH_VIP_URL = "https://api.twitch.tv/helix/channels/vips"
const TWITCH_SETTINGS_URL = "https://api.twitch.tv/helix/chat/settings"
const TWITCH_CHATTERS_URL = "https://api.twitch.tv/helix/chat/chatters"


var _scopes: PackedStringArray
var _client_id: String

var _user: TwitchChannel

func initiate_twitch_auth():
	_scopes = TwitchSettings.get_setting(TwitchSettings.settings.scopes)
	_client_id = TwitchSettings.get_setting(TwitchSettings.settings.client_id)
	var redirect_host = TwitchSettings.get_setting(TwitchSettings.settings.redirect_host)
	var redirect_port = TwitchSettings.get_setting(TwitchSettings.settings.redirect_port)
	var uuid = TwitchSettings.get_setting(TwitchSettings.settings.uuid)

	var auth_server = TwitchAuthServer.new()
	add_child(auth_server)
	auth_server.OnTokenReceived.connect(_on_auth_server_on_token_received)
	auth_server.stop_server()
	auth_server.start_server(redirect_port)

	var redirect_uri = redirect_host + str(redirect_port) + "/" + uuid
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
