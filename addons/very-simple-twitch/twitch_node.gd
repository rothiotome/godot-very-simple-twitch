extends Node

signal token_received(TwitchChannel)
signal chat_message_received(Chatter)

var _twitch_api: TwitchAPI
var _twitch_chat: TwitchChat

func login_chat_anon(channel_name: String):
	_start_chat_client()
	_twitch_chat.login_anon(channel_name)


func login_chat(channel_info: TwitchChannel):
	_start_chat_client()
	_twitch_chat.login(channel_info)


func get_token_and_login_chat():
	var channel_info =  await get_token()
	login_chat(channel_info)


func _start_chat_client():
	if !_twitch_chat:
		_twitch_chat = TwitchChat.new()
		add_child(_twitch_chat)
		_twitch_chat.OnMessage.connect(on_chat_message_received)


func get_token() -> TwitchChannel:
	if !_twitch_api:
		_twitch_api = TwitchAPI.new()
		add_child(_twitch_api)
		_twitch_api.initiate_twitch_auth()
	var channel_info = await _twitch_api.token_received
	token_received.emit(channel_info)
	return channel_info


func get_badge(badge_name: String, badge_level: String, channel_id: String = "_global", scale: String = "1"):
	return await _twitch_chat.get_badge(badge_name, badge_level, channel_id, scale)


func get_emote(loc_id: String):
	return await _twitch_chat.get_emote(loc_id)


func vip():
	pass


func remove_vip():
	pass


func timeout():
	pass


func remove_timeout():
	pass

func send_chat_message(message: String):
	_twitch_chat.send_message(message)

func on_chat_message_received(chatter: Chatter):
	chat_message_received.emit(chatter)
