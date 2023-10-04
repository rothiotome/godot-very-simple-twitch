extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	$TwitchAPI.initiate_twitch_auth()
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_twitch_api_on_token_received(channel_info:TwitchChannel):
	$TwitchChat.start_chat_client(channel_info)
