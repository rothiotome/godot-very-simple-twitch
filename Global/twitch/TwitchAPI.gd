extends Node

class_name TwitchAPI

@export var scopes:Array[String] = ["moderator:manage:banned_users","chat:read", "channel:manage:vips"]

const RESPONSE_TYPE = 'token'

const TWITCH_VALIDATE_URL = "https://id.twitch.tv/oauth2/validate"
const TWITCH_BAN_URL = "https://api.twitch.tv/helix/moderation/bans"
const TWITCH_OAUTH_URL = "https://id.twitch.tv/oauth2/authorize"
const TWITCH_VIP_URL = "https://api.twitch.tv/helix/channels/vips"
const TWITCH_SETTINGS_URL = "https://api.twitch.tv/helix/chat/settings"
const TWITCH_CHATTERS_URL = "https://api.twitch.tv/helix/chat/chatters"

const TWITCH_REDIRECT_HOST = "http://localhost:"

const USELESS_UUID = "53125396-3e32-4fad-8f7e-36475724168b-a8fe83ab-3373-4a6a-8967-2532eafe407f-41483db3-f011-4a23-80da-9a340672692a-e755c6d4-c546-43ce-b722-b5a799561b4e-5ba1697d-79b2-4d5d-96c3-f0d91f13f583-f08f18f9-bd56-4a0f-a597-96f90108cd85-14449d50-6cc9-450f-8119-ff4c525e31db-e41a6912-92a0-48b6-b6d3-845c21bea7eb-7dfd7948-2976-42cf-9cca-b23ae5854813-107224eb-81ea-46dd-9bf5-9ebbfcfc45dc/"

var free_port:int = 8090

@export var port_list:Array[int] = [8091,8078,8090]
@export var clientId = "oes235t6q9gglv9rsoyozsfvg66h34"

@onready var authServer:Node = $AuthServer

signal OnTokenReceived(TwitchChannel)

var _user:TwitchChannel

func initiate_twitch_auth():
	authServer.stopServer()
	authServer.startServer()

	var redirect_uri = TWITCH_REDIRECT_HOST + str(free_port) + "/" + USELESS_UUID
	var scopes_string = "+".join(scopes)
	var url = "client_id=" + clientId + "&redirect_uri=" + redirect_uri + "&response_type=" + RESPONSE_TYPE + "&scope=" + scopes_string

	OS.shell_open(TWITCH_OAUTH_URL + "?" + url)

func _on_auth_server_on_token_received(token) -> void:
	authServer.stopServer()
	var validatedUser = await validateTokenAndGetUserId(token)
	if !(validatedUser):
		print('Invalid token')
		_user = null
		return
	_user = validatedUser
	OnTokenReceived.emit(_user)

func sendAPIRequest(url: String, method: HTTPClient.Method,  body: Dictionary = {}):
	var client = HTTPRequest.new()
	var bodyEncoded = JSON.stringify(body)
	add_child(client)
	client.request(url, [
		'Client-Id: ' + clientId,
		'Authorization: Bearer ' + _user.token,
		'Content-Type: application/json'
	], method, bodyEncoded)
	var result = await client.request_completed
	var status = result[1]
	if status == 401 or status == 403:
		#Unauthorized? No mi ciela
		initiate_twitch_auth()
		return

	if status != 200:
		var data = (result[3] as PackedByteArray).get_string_from_utf8()
		print(data)
		return false

	client.queue_free()
	return true

func validateTokenAndGetUserId(token: String):
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
	var dataParsed = JSON.parse_string(data)
	var user = TwitchChannel.new()
	user.id = dataParsed['user_id']
	user.login = dataParsed['login']
	user.token = token
	client.queue_free()
	return user	

func timeoutUser(userToBanId: String, duration: int = 1, reason: String = ''):
	if !_user:
		return

	var timeoutDuration = max(duration, 1)
	var url = TWITCH_BAN_URL + '?broadcaster_id=' +  _user.id + '&moderator_id=' + _user.id
	var body = {
		data = {
			user_id = userToBanId,
			duration = timeoutDuration,
			reason = reason
		},
	}
	return await sendAPIRequest(url, HTTPClient.METHOD_POST, body)

func addVip(userId: String):
	if !_user:
		return

	print('adding vip to user ', userId)
	var url = TWITCH_VIP_URL + '?broadcaster_id=' +  _user.id + '&user_id=' + userId
	return await sendAPIRequest(url, HTTPClient.METHOD_POST)

func removeVip(userId: String):
	if !_user:
		return

	print('removing vip to user ', userId)
	var url = TWITCH_VIP_URL + '?broadcaster_id=' +  _user.id + '&user_id=' + userId
	return await sendAPIRequest(url, HTTPClient.METHOD_DELETE)

