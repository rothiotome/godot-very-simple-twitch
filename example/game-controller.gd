extends Node

@onready var chatContainer: ChatContainer = %ChatContainer

func _ready():
	VerySimpleTwitch.chat_message_received.connect(on_chat_message_received)
	VerySimpleTwitch.get_token()

func on_chat_message_received(chatter: Chatter):
	chatContainer.create_chatter_msg(chatter)
