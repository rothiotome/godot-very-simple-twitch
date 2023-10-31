extends Node2D

@onready var chatContainer: ChatContainer = $CanvasLayer/Control/ChatContainer

var number_of_messages:=0

func _ready():
	$TwitchAPI.initiate_twitch_auth()

func _on_twitch_api_on_token_received(channel_info:TwitchChannel):
	$TwitchChat.start_chat_client(channel_info)

func _on_twitch_chat_on_message(chatter: Chatter):
	chatContainer.create_chatter_msg(chatter)
