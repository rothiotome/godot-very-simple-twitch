extends GutTest

var server:VSTAuthServer

func test_initial_settings():
	var client_id:String = VSTSettings.get_setting(VSTSettings.settings.client_id)
	assert_eq(client_id, "") # no initial value
	assert_eq(VSTSettings.settings.client_id.path, "config/client_id")
	
	var twitch_chat_url:String = VSTSettings.get_setting(VSTSettings.settings.twitch_chat_url)
	assert_eq(twitch_chat_url, "wss://irc-ws.chat.twitch.tv")
	assert_eq(VSTSettings.settings.twitch_chat_url.path, "advanced_config/twitch_chat_url")
	
	var twitch_chat_port:int = VSTSettings.get_setting(VSTSettings.settings.twitch_port)
	assert_eq(twitch_chat_port, 443)
	assert_eq(VSTSettings.settings.twitch_port.path, "advanced_config/twitch_port")
	
	var use_cache:bool = VSTSettings.get_setting(VSTSettings.settings.disk_cache)
	assert_eq(use_cache, true)
	assert_eq(VSTSettings.settings.disk_cache.path, "config/disk_cache")
	
	var cache_path:String = VSTSettings.get_setting(VSTSettings.settings.disk_cache_path)
	assert_eq(cache_path, "user://very-simple-chat/cache")
	assert_eq(VSTSettings.settings.disk_cache_path.path, "advanced_config/disk_cache_path")
	
	var chat_timeout_ms:int = VSTSettings.get_setting(VSTSettings.settings.twitch_timeout_ms)
	assert_eq(chat_timeout_ms, 320)
	assert_eq(VSTSettings.settings.twitch_timeout_ms.path, "advanced_config/twitch_timeout_ms")
	
	var scopes:Array = VSTSettings.get_setting(VSTSettings.settings.scopes)
	assert_eq_deep(scopes, ["moderator:manage:banned_users","chat:read", "channel:manage:vips"])
	assert_eq(VSTSettings.settings.scopes.path, "config/scopes")
	
	var twitch_anon_user:String = VSTSettings.get_setting(VSTSettings.settings.twitch_anon_user)
	assert_eq(twitch_anon_user, "justinfan5555")
	assert_eq(VSTSettings.settings.twitch_anon_user.path, "advanced_config/twitch_anon_user")
	
	var twitch_anon_pass:String = VSTSettings.get_setting(VSTSettings.settings.twitch_anon_pass)
	assert_eq(twitch_anon_pass, "kappa")
	assert_eq(VSTSettings.settings.twitch_anon_pass.path, "advanced_config/twitch_anon_pass")

func test_parse_message_to_chatter():
	var twitch_chat:VSTChat = load("res://addons/very-simple-twitch/twitch_chat.gd").new()
	var parsed_message:PackedStringArray = twitch_chat.parse_message_from_twtich_IRC("@badge-info=;badges=broadcaster/1;client-nonce=28e05b1c83f1e916ca1710c44b014515;color=#0000FF;display-name=godot_oficial;emotes=62835:0-10;first-msg=0;flags=;id=f80a19d6-e35a-4273-82d0-cd87f614e767;mod=0;room-id=713936733;subscriber=0;tmi-sent-ts=1642696567751;turbo=0;user-id=713936733;user-type= :godot_oficial!godot_oficial@godot_oficial.tmi.twitch.tv PRIVMSG #xyz :HeyGuys")
	var chatter:VSTChatter = twitch_chat.parse_message_to_chatter(parsed_message)
	assert_eq(chatter.channel, "xyz")
	assert_eq(chatter.login, "godot_oficial")
	assert_eq(chatter.message, "HeyGuys")
	assert_eq(chatter.is_mod(), false)
	assert_eq(chatter.is_sub(), false)
	assert_eq(chatter.is_broadcaster(), true)
	
func test_handle_private_message():
	var twitch_chat:VSTChat = load("res://addons/very-simple-twitch/twitch_chat.gd").new()
	watch_signals(twitch_chat)
	var parsed_message:PackedStringArray = twitch_chat.parse_message_from_twtich_IRC("@badge-info=;badges=broadcaster/1;client-nonce=28e05b1c83f1e916ca1710c44b014515;color=#0000FF;display-name=godot_oficial;emotes=62835:0-10;first-msg=0;flags=;id=f80a19d6-e35a-4273-82d0-cd87f614e767;mod=0;room-id=713936733;subscriber=0;tmi-sent-ts=1642696567751;turbo=0;user-id=713936733;user-type= :godot_oficial!godot_oficial@godot_oficial.tmi.twitch.tv PRIVMSG #xyz :HeyGuys")
	twitch_chat.handle_privmsg(parsed_message)
	var chatter:VSTChatter = twitch_chat.parse_message_to_chatter(parsed_message)
	assert_signal_emitted(twitch_chat, "OnMessage", [chatter])
