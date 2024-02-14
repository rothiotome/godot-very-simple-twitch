@tool
extends EditorPlugin

var dock
var chat_dock

func _enter_tree() -> void:
	add_custom_type("VerySimpleTwitchChat", "Node", preload("twitch_chat.gd"), preload("icon.png"))
	add_custom_type("VerySimpleTwitchAPI", "Node", preload("twitch_api.gd"), preload("icon.png"))
	
	add_autoload_singleton("VerySimpleTwitch", "twitch_node.gd")
	
	TwitchSettings.add_settings()
	
	#Bottom setup dock
	dock = preload("res://addons/very-simple-twitch/dock/vst-dock.tscn").instantiate()
	add_control_to_bottom_panel(dock, "Very Simple Twitch")
	
	#Chat dock
	chat_dock = preload("res://addons/very-simple-twitch/chat/vst_chat_dock.tscn").instantiate()
	add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_UL, chat_dock)


func _exit_tree() -> void:
	remove_custom_type("VerySimpleTwitchChat")
	remove_custom_type("VerySimpleTwitchAPI")
	
	TwitchSettings.remove_settings()
	
	remove_autoload_singleton("VerySimpleTwitch")
	
	remove_control_from_bottom_panel(dock)
	dock.free()

	remove_control_from_docks(chat_dock)
	chat_dock.free()
