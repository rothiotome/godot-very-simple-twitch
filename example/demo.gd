extends Node

@onready var login_layout: VBoxContainer = $VBoxContainer/HBoxContainer/LoginLayout
@onready var logged_in_layout: VBoxContainer = $VBoxContainer/HBoxContainer/LoggedInLayout

func login_anon():
	VerySimpleTwitch.login_chat_anon(%ChannelName.text)
	show_logout_layout()

func login_token():
	VerySimpleTwitch.get_token_and_login_chat()
	show_logout_layout()

func logout():
	VerySimpleTwitch.end_chat_client()
	%TwitchChat.clear()
	show_login_layout()

func show_login_layout():
	logged_in_layout.visible = false
	login_layout.visible = true
	%ChannelName.editable = true

func show_logout_layout():
	logged_in_layout.visible = true
	login_layout.visible = false
	%ChannelName.editable = false


func clear_chat() -> void:
	%TwitchChat.clear()
