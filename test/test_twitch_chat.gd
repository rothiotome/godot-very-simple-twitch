extends GutTest

var server:TwitchAuthServer

func test_initial_settings():
	var client_id = TwitchSettings.get_setting(TwitchSettings.settings.client_id)
	assert_eq(client_id, "") # no initial value
	assert_eq(TwitchSettings.settings.client_id.path, "config/client_id")
	
	var twitch_chat_url = TwitchSettings.get_setting(TwitchSettings.settings.twitch_chat_url)
	assert_eq(twitch_chat_url, "wss://irc-ws.chat.twitch.tv")
	assert_eq(TwitchSettings.settings.twitch_chat_url.path, "advanced_config/twitch_chat_url")
	
	var twitch_chat_port = TwitchSettings.get_setting(TwitchSettings.settings.twitch_port)
	assert_eq(twitch_chat_port, 443)
	assert_eq(TwitchSettings.settings.twitch_port.path, "advanced_config/twitch_port")
	
	var use_cache = TwitchSettings.get_setting(TwitchSettings.settings.disk_cache)
	assert_eq(use_cache, true)
	assert_eq(TwitchSettings.settings.disk_cache.path, "config/disk_cache")
	
	var cache_path = TwitchSettings.get_setting(TwitchSettings.settings.disk_cache_path)
	assert_eq(cache_path, "user://very-simple-chat/cache")
	assert_eq(TwitchSettings.settings.disk_cache_path.path, "advanced_config/disk_cache_path")
	
	var chat_timeout_ms = TwitchSettings.get_setting(TwitchSettings.settings.twitch_timeout_ms)
	assert_eq(chat_timeout_ms, 320)
	assert_eq(TwitchSettings.settings.twitch_timeout_ms.path, "advanced_config/twitch_timeout_ms")
	
	var scopes = TwitchSettings.get_setting(TwitchSettings.settings.scopes)
	assert_eq_deep(scopes, ["moderator:manage:banned_users","chat:read", "channel:manage:vips"])
	assert_eq(TwitchSettings.settings.scopes.path, "config/scopes")
	
	var twitch_anon_user = TwitchSettings.get_setting(TwitchSettings.settings.twitch_anon_user)
	assert_eq(twitch_anon_user, "justinfan5555")
	assert_eq(TwitchSettings.settings.twitch_anon_user.path, "advanced_config/twitch_anon_user")
	
	var twitch_anon_pass = TwitchSettings.get_setting(TwitchSettings.settings.twitch_anon_pass)
	assert_eq(twitch_anon_pass, "kappa")
	assert_eq(TwitchSettings.settings.twitch_anon_pass.path, "advanced_config/twitch_anon_pass")

var twitch_chat_res = load("res://addons/very-simple-twitch/twitch_chat.gd")

func _handle_messages_util(message:String, result:String):
	var twitch_chat:TwitchChat  = partial_double(twitch_chat_res, DOUBLE_STRATEGY.INCLUDE_NATIVE).new()
	var peer_socket = double(WebSocketPeer).new()
	stub(peer_socket, "get_ready_state").to_return(WebSocketPeer.STATE_OPEN)
	stub(peer_socket, "send_text").to_do_nothing()
	twitch_chat._chatClient = peer_socket
	twitch_chat.handle_message(message)
	assert_called(peer_socket, "send_text", [result])

func test_handle_ping():
	_handle_messages_util("PING test", "PONG test")


func test_handle_welcome():
	_handle_messages_util(":tmi.godot.com 001 testTwtichGodot :Welcome, GLHF!", "ROOMSTATE # test")


func test_handle_notice():
	pending('This test is not implemented yet')


func test_handle_private_message():
	pending('This test is not implemented yet')


func test_handle_room_state():
	pending('This test is not implemented yet')
