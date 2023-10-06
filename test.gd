extends Node2D

func _ready():
	$TwitchAPI.initiate_twitch_auth()

func _process(delta):
	pass

func _on_twitch_api_on_token_received(channel_info:TwitchChannel):
	$TwitchChat.start_chat_client(channel_info)
