@tool
extends EditorPlugin

var dock

func _enter_tree() -> void:
	add_custom_type("VerySimpleTwitchChat", "Node", preload("twitch_chat.gd"), preload("icon.png"))
	add_custom_type("VerySimpleTwitchAPI", "Node", preload("twitch_api.gd"), preload("icon.png"))
	
	add_autoload_singleton("VerySimpleTwitch", "twitch_node.gd")
	
	TwitchSettings.add_settings()
	dock = preload("res://addons/very-simple-twitch/dock/vst-dock.tscn").instantiate()
	add_control_to_bottom_panel(dock, "Very Simple Twitch")

func _exit_tree() -> void:
	remove_custom_type("VerySimpleTwitchChat")
	remove_custom_type("VerySimpleTwitchAPI")
	
	TwitchSettings.remove_settings()
	
	remove_autoload_singleton("VerySimpleTwitch")
	
	remove_control_from_bottom_panel(dock)
	dock.free()
