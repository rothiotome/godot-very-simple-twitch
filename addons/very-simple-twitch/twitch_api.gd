class_name VSTAPI

extends Node

signal token_received(TwitchChannel)

const RESPONSE_TYPE = 'token'

const TWITCH_VALIDATE_URL = "https://id.twitch.tv/oauth2/validate"
const TWITCH_BAN_URL = "https://api.twitch.tv/helix/moderation/bans"
const TWITCH_OAUTH_URL = "https://id.twitch.tv/oauth2/authorize"
const TWITCH_VIP_URL = "https://api.twitch.tv/helix/channels/vips"
const TWITCH_SETTINGS_URL = "https://api.twitch.tv/helix/chat/settings"
const TWITCH_CHATTERS_URL = "https://api.twitch.tv/helix/chat/chatters"


var auth_server: VSTAuthServer

var _scopes: PackedStringArray
var _client_id: String
var _user: VSTChannel

func initiate_twitch_auth():
	_scopes = VSTSettings.get_setting(VSTSettings.settings.scopes)
	_client_id = VSTSettings.get_setting(VSTSettings.settings.client_id)
	var redirect_host = VSTSettings.get_setting(VSTSettings.settings.redirect_host)
	var redirect_port = VSTSettings.get_setting(VSTSettings.settings.redirect_port)
	var uuid = VSTSettings.get_setting(VSTSettings.settings.uuid)

	if auth_server:
		disconnect_api()

	auth_server = VSTAuthServer.new()
	add_child(auth_server)
	auth_server.OnTokenReceived.connect(_on_auth_server_on_token_received)
	auth_server.start_server(redirect_port)

	var redirect_uri = redirect_host + str(redirect_port) + "/" + uuid
	var scopes_string = "+".join(_scopes)
	var url = "client_id=" + _client_id
	url += "&redirect_uri=" +redirect_uri
	url += "&response_type=" + RESPONSE_TYPE
	url += "&scope=" + scopes_string

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
	var user = VSTChannel.new()
	user.id = data_parsed['user_id']
	user.login = data_parsed['login']
	user.token = token
	client.queue_free()
	return user

func timeout_user(user_to_ban_id: String, duration: int = 1, reason: String = '',
				on_success: Callable = Callable(), on_fail: Callable = Callable()) -> void:
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

	var vst = VSTNetwork_Call.new()
	vst.to(TWITCH_BAN_URL)
	vst.add_all_get_params({
		'broadcaster_id': _user.id,
		'moderator_id': _user.id
	}).\
	vst.with(body)
	vst.verb(HTTPClient.METHOD_POST)
	vst.add_all_headers({
		'Client-Id: ' : _client_id,
		'Authorization': 'Bearer ' + _user.token,
		'Content-Type': 'application/json'
	})
	vst.set_on_call_success(on_success)
	vst.set_on_call_fail(request_fail.bind(on_fail))
	vst.launch_request(self)


func add_vip(user_to_vip_id: String, on_success: Callable = Callable(),
			on_fail: Callable = Callable()):
	if !_user:
		return

	var vst = VSTNetwork_Call.new()
	vst.to(TWITCH_VIP_URL)
	vst.add_all_get_params({
		'broadcaster_id': _user.id,
		'user_id': user_to_vip_id
	})
	vst.verb(HTTPClient.METHOD_POST)
	vst.add_all_headers({
		'Client-Id: ' : _client_id,
		'Authorization': 'Bearer ' + _user.token,
		'Content-Type': 'application/json'
	})
	vst.set_on_call_success(on_success)
	vst.set_on_call_fail(request_fail.bind(on_fail))

	vst.launch_request(self)

func remove_vip(user_to_remove_vip_id: String, on_success: Callable = Callable(),
				on_fail: Callable = Callable()) -> void:
	if !_user:
		return

	var vst = VSTNetwork_Call.new()
	vst.to(TWITCH_VIP_URL)
	vst.add_all_get_params({
		'broadcaster_id': _user.id,
		'user_id': user_to_remove_vip_id
	})
	vst.verb(HTTPClient.METHOD_DELETE)
	vst.add_all_headers({
		'Client-Id: ' : _client_id,
		'Authorization': 'Bearer ' + _user.token,
		'Content-Type': 'application/json'
	})
	vst.set_on_call_success(on_success)
	vst.set_on_call_fail(request_fail.bind(on_fail))

	vst.launch_request(self)


func disconnect_api():
	if auth_server:
		auth_server.stop_server()
		remove_child(auth_server)
