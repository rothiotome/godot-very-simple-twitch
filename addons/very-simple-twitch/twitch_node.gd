extends Node

signal token_received(twitch_channel: VSTChannel)
signal chat_message_received(channel: VSTChatter)
signal chat_connected(channel_name: String)

var _twitch_api: VSTAPI
var _twitch_chat: VSTChat

func login_chat_anon(channel_name: String):
	_start_chat_client()
	_twitch_chat.login_anon(channel_name)
	chat_connected.emit(await _twitch_chat.Connected)


func login_chat(channel_info: VSTChannel):
	_start_chat_client()
	_twitch_chat.login(channel_info)
	chat_connected.emit(await _twitch_chat.Connected)


func get_token_and_login_chat():
	var channel_info =  await get_token()
	await login_chat(channel_info)


func _start_chat_client():
	if !_twitch_chat:
		_twitch_chat = VSTChat.new()
		add_child(_twitch_chat)
		_twitch_chat.OnMessage.connect(on_chat_message_received)


func get_token() -> VSTChannel:
	if !_twitch_api:
		_twitch_api = VSTAPI.new()
		add_child(_twitch_api)
		_twitch_api.initiate_twitch_auth()
	var channel_info = await _twitch_api.token_received
	token_received.emit(channel_info)
	return channel_info


func get_badge(badge_name: String, badge_level: String,
	channel_id: String = "_global", scale: String = "1"):
	return await _twitch_chat.get_badge(badge_name, badge_level, channel_id, scale)


func get_emote(loc_id: String):
	return await _twitch_chat.get_emote(loc_id)

# clear all support nodes, disconects from chat/auth server
func end_chat_client():
	if _twitch_chat:
		_twitch_chat.disconnect_api()
		_twitch_chat.OnMessage.disconnect(on_chat_message_received)
		remove_child(_twitch_chat)
		_twitch_chat.queue_free()
		_twitch_chat = null

	if _twitch_api:
		_twitch_api.disconnect_api()
		remove_child(_twitch_api)
		_twitch_api.queue_free()
		_twitch_api = null

func send_chat_message(message: String):
	_twitch_chat.send_message(message)

func on_chat_message_received(chatter: VSTChatter):
	chat_message_received.emit(chatter)

## Return if puglin is connected to the twitch channel. This method may take some time
## because if there are no new messages the plugin will send a message and wait for a message 
## from twtich
func check_connection() -> bool:
	# first and naive checks for connection status
	if !_twitch_chat: 
		return false
	if !_twitch_chat._hasConnected: 
		return false
	# needs to be deferred because can return a saved value instant without awaiting
	_twitch_chat.call_deferred("is_connected_to_chat")
	return await _twitch_chat.on_conection_check_request

## Return the timestamp (unix format) of the last time you receive a message from twitch chat
func get_last_time_message() -> int:
	return _twitch_chat.last_ping_unix_time
