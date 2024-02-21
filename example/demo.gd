extends Node

func login_anon():
	VerySimpleTwitch.login_chat_anon(%ChannelName.text)

func login_token():
	VerySimpleTwitch.get_token_and_login_chat()

func get_token():
	VerySimpleTwitch.get_token()

func send_message():
	VerySimpleTwitch.send_chat_message("Hello world")
