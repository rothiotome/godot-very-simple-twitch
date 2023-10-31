@tool
extends EditorPlugin

func _enter_tree() -> void:
	add_custom_type("VerySimpleTwitchChat", "Node", preload("twitch_chat.gd"), preload("icon.png"))
	add_custom_type("VerySimpleTwitchAPI", "Node", preload("twitch_api.gd"), preload("icon.png"))

func _exit_tree() -> void:
	remove_custom_type("VerySimpleTwitchChat")
	remove_custom_type("VerySimpleTwitchAPI")
