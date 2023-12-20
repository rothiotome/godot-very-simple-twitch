extends Node

signal token_received
signal chat_message_received(Chatter)

var _twitch_api: TwitchAPI
var _twitch_chat: TwitchChat

var _channel_info: TwitchChannel


func get_token():
	if !_twitch_api:
		_twitch_api = TwitchAPI.new()
		add_child(_twitch_api)
		_twitch_api.initiate_twitch_auth()
		_twitch_api.token_received.connect(on_token_received)
	
func login_chat():
	if !_twitch_chat:
		_twitch_chat = TwitchChat.new()
		add_child(_twitch_chat)
		_twitch_chat.start_chat_client(_channel_info)
		_twitch_chat.OnMessage.connect(on_chat_message_received)

func get_badge(badge_name: String, badge_level: String, channel_id: String = "_global", scale: String = "1"):
	return await _twitch_chat.get_badge(badge_name, badge_level, channel_id, scale)

func get_emote(loc_id: String):
	return await _twitch_chat.get_emote(loc_id)

func add_vip():
	pass

func remove_vip():
	pass
	
func add_timeout():
	pass

func remove_timeout():
	pass

func on_chat_message_received(chatter: Chatter):
	chat_message_received.emit(chatter)

func on_token_received(channel: TwitchChannel):
	_channel_info = channel
	login_chat()
	token_received.emit()
