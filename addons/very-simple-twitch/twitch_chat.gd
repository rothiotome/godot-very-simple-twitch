@tool
extends Node

class_name TwitchChat

signal OnSucess
signal OnMessage(chatter: Chatter)
signal OnFailure(reason: String)

var _channel: TwitchChannel

var _chatClient: WebSocketPeer
var _hasConnected:= false

enum RequestType {
	EMOTE,
	BADGE,
	BADGE_MAPPING
}

var caches := {
	RequestType.EMOTE: {},
	RequestType.BADGE: {},
	RequestType.BADGE_MAPPING: {}
}

var _client_id: String
var _twitch_chat_url: String
var _twitch_chat_port: int

var _use_cache: bool
var _cache_path: String

var _use_anon_connection:= false

var _chat_queue : Array[String] = []
var _last_msg : int = Time.get_ticks_msec()
var _chat_timeout_ms: int

const USER_AGENT : String = "User-Agent: VSTC/0.1.0 (Godot Engine)"

func _process(_delta: float):
	if !_chatClient:
		return

	_chatClient.poll()
	var state = _chatClient.get_ready_state()
	match state:
		WebSocketPeer.STATE_OPEN:
			if (!_hasConnected):
				onChatConnected()
			while _chatClient.get_available_packet_count():
				onReceivedData(_chatClient.get_packet())
			if !_chat_queue.is_empty() and _last_msg + (_last_msg + _chat_timeout_ms) <= Time.get_ticks_msec():
				_chatClient.send_text(_chat_queue.pop_front())
				_last_msg = Time.get_ticks_msec()
		WebSocketPeer.STATE_CLOSED:
			if _hasConnected:
				_hasConnected = false
				var code = _chatClient.get_close_code()
				var reason = _chatClient.get_close_reason()
				print('Disconnected from twitch chat')
				print("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
				print("Reconnecting")
				start_chat_client()

func start_chat_client():
	get_settings()
	if _chatClient:
		_chatClient.close()
	_chatClient = WebSocketPeer.new()
	_chatClient.connect_to_url("%s:%d" % [_twitch_chat_url, _twitch_chat_port])


func login_anon(channel_name: String):
	_channel = TwitchChannel.new()
	_channel.login = channel_name.to_lower()
	_use_anon_connection = true
	start_chat_client()


func login(twitch_channel: TwitchChannel):
	_channel = twitch_channel
	start_chat_client()


func onChatConnected():
	if !_channel:
		return
	_hasConnected = true
	
	_chatClient.send_text("CAP REQ :twitch.tv/tags twitch.tv/commands")
	
	if _use_anon_connection:
		_chatClient.send_text('PASS ' + TwitchSettings.get_setting(TwitchSettings.settings.twitch_anon_pass))
		_chatClient.send_text('NICK ' + TwitchSettings.get_setting(TwitchSettings.settings.twitch_anon_user))
	else:
		_chatClient.send_text('PASS oauth:' + _channel.token)
		_chatClient.send_text('NICK ' + _channel.login.to_lower())
		pass
		
	_chatClient.send_text('JOIN ' + '#' + _channel.login.to_lower())
	OnSucess.emit()

func send_message(message: String):
	_chat_queue.append("PRIVMSG #" + _channel.login.to_lower() + " :" + message + "\r\n")

func onReceivedData(payload: PackedByteArray):
	var message = payload.get_string_from_utf8()
	var splittled_messages = message.split("\n")
	for n in splittled_messages:
		handle_message(n)
		
func handle_message(message: String):
	if message.begins_with("PING"):
		_chatClient.send_text(message.replace("PING", "PONG"))
		return

	var parsed_message: PackedStringArray = message.split(" ", true, 4) # We might need more than 3
	
	if parsed_message.size() < 2: return

	match parsed_message[2]:
		"NOTICE":
			var info : String = parsed_message[3].right(-1)
			if (info == "Login authentication failed" || info == "Login unsuccessful"):
				print_debug("Authentication failed.")
				#login_attempt.emit(false)
			elif (info == "You don't have permission to perform that action"):
				print_debug("No permission. Check if access token is still valid. Aborting.")
				#user_token_invalid.emit()
				set_process(false)
			else:
				pass
				#unhandled_message.emit(message, tags)
		"001":
			print_debug("Authentication successful.")
			_chatClient.send_text('ROOMSTATE '+ '#' + _channel.login.to_lower())
			#login_attempt.emit(true)
		"PRIVMSG":
			handle_privmsg(parsed_message)
			#handle_command(sender_data, msg[3].split(" ", true, 1))
			#chat_message.emit(sender_data, msg[3].right(-1))
		"ROOMSTATE":
			if _use_anon_connection:
				var parsed_tags:IRCTags = TwitchParseHelper.parse_tags(parsed_message[0])
				_channel.id = parsed_tags.user_id

func handle_privmsg(msg: PackedStringArray):
	var chatter = Chatter.new()
	chatter.login = TwitchParseHelper.parse_login(msg[1])
	chatter.channel = TwitchParseHelper.parse_channel(msg[3])
	chatter.message = TwitchParseHelper.parse_message(msg[4])
	chatter.tags = TwitchParseHelper.parse_tags(msg[0])
	chatter.date_time_dict = Time.get_datetime_dict_from_system()
	
	if chatter.tags.color_hex.is_empty():
		chatter.tags.color_hex = TwitchUtils.get_random_name_color(chatter.login)
		
	OnMessage.emit(chatter)

func get_emote(emote_id: String, scale: String = "1.0") -> Texture2D:
	var texture: Texture2D
	var cachename: String = emote_id + "_" + scale
	var filename: String = _cache_path + "/" + RequestType.keys()[RequestType.EMOTE] + "/" + cachename + ".png"
	
	if !caches[RequestType.EMOTE].has(cachename):
		if _use_cache && FileAccess.file_exists(filename):
			var img: Image = Image.new()
			img.load_png_from_buffer(FileAccess.get_file_as_bytes(filename))
			texture = ImageTexture.create_from_image(img)
			texture.take_over_path(filename)
		else:
			var request: HTTPRequest = HTTPRequest.new()
			add_child(request)
			request.request("https://static-cdn.jtvnw.net/emoticons/v1/" + emote_id + "/" + scale, [USER_AGENT,"Accept: */*"])
			var data = await(request.request_completed)
			var img: Image = Image.new()
			img.load_png_from_buffer(data[3])
			texture = ImageTexture.create_from_image(img)
			if _use_cache:
				DirAccess.make_dir_recursive_absolute(filename.get_base_dir())
				texture.get_image().save_png(filename)
			request.queue_free()
			texture.take_over_path(filename)
		caches[RequestType.EMOTE][cachename] = texture
	return caches[RequestType.EMOTE][cachename]

func get_badge(badge_name: String, badge_level: String, channel_id: String = "_global", scale: String = "1") -> Texture2D:
	if _use_anon_connection: return
	
	var texture: Texture2D
	var cachename = badge_name + "_" + badge_level + "_" + scale
	var filename: String = _cache_path + "/" + RequestType.keys()[RequestType.BADGE] + "/" + channel_id + "/" + cachename + ".png"
	if !caches[RequestType.BADGE].has(channel_id):
		caches[RequestType.BADGE][channel_id] = {}
	if !caches[RequestType.BADGE][channel_id].has(cachename):
		if _use_cache && FileAccess.file_exists(filename):
			var img : Image = Image.new()
			img.load_png_from_buffer(FileAccess.get_file_as_bytes(filename))
			texture = ImageTexture.create_from_image(img)
			texture.take_over_path(filename)
		else:
			var map: Dictionary = caches[RequestType.BADGE_MAPPING].get(channel_id, await(get_badge_mapping(channel_id)))
			if !map.is_empty():
				if map.has(badge_name):
					var request: HTTPRequest = HTTPRequest.new()
					add_child(request)
					request.request(map[badge_name]["versions"][badge_level]["image_url_" + scale + "x"], [USER_AGENT,"Accept: */*"])
					var data = await(request.request_completed)
					var img: Image = Image.new()
					img.load_png_from_buffer(data[3])
					texture = ImageTexture.create_from_image(img)
					texture.take_over_path(filename)
					request.queue_free()
				elif channel_id != "_global":
					return await(get_badge(badge_name, badge_level, "_global", scale))
			elif channel_id != "_global":
				return await(get_badge(badge_name, badge_level, "_global", scale))
			if _use_cache:
				DirAccess.make_dir_recursive_absolute(filename.get_base_dir())
				texture.get_image().save_png(filename)
		texture.take_over_path(filename)
		caches[RequestType.BADGE][channel_id][cachename] = texture
	return caches[RequestType.BADGE][channel_id][cachename]

func get_badge_mapping(channel_id: String = "_global") -> Dictionary:
	
	if _use_anon_connection: return {}
		
	if caches[RequestType.BADGE_MAPPING].has(channel_id):
		return caches[RequestType.BADGE_MAPPING][channel_id]

	var filename: String = _cache_path + "/" + RequestType.keys()[RequestType.BADGE_MAPPING] + "/" + channel_id + ".json"
	if _use_cache && FileAccess.file_exists(filename):
		var cache = JSON.parse_string(FileAccess.get_file_as_string(filename))
		if "badge_sets" in cache:
			return cache["badge_sets"]

	var request : HTTPRequest = HTTPRequest.new()
	add_child(request)
	
	request.request("https://api.twitch.tv/helix/chat/badges" + ("/global" if channel_id == "_global" else "?broadcaster_id=" + _channel.id), [USER_AGENT, "Authorization: Bearer " + _channel.token, "Client-Id:" + _client_id, "Content-Type: application/json"], HTTPClient.METHOD_GET)
	
	var reply : Array = await(request.request_completed)
	var response : Dictionary = JSON.parse_string(reply[3].get_string_from_utf8())
	var mappings : Dictionary = {}
	for entry in response["data"]:
		if (!mappings.has(entry["set_id"])):
			mappings[entry["set_id"]] = {"versions": {}}
		for version in entry["versions"]:
			mappings[entry["set_id"]]["versions"][version["id"]] = version
	request.queue_free()
	if (reply[1] == HTTPClient.RESPONSE_OK):
		caches[RequestType.BADGE_MAPPING][channel_id] = mappings
		if _use_cache:
			DirAccess.make_dir_recursive_absolute(filename.get_base_dir())
			var file : FileAccess = FileAccess.open(filename, FileAccess.WRITE)
			file.store_string(JSON.stringify(mappings))
	else:
		print("Could not retrieve badge mapping for channel_id " + channel_id + ".")
		return {}
	return caches[RequestType.BADGE_MAPPING][channel_id]

func get_settings():
	_client_id = TwitchSettings.get_setting(TwitchSettings.settings.client_id)
	_twitch_chat_url = TwitchSettings.get_setting(TwitchSettings.settings.twitch_chat_url)
	_twitch_chat_port = TwitchSettings.get_setting(TwitchSettings.settings.twitch_port)
	_use_cache = TwitchSettings.get_setting(TwitchSettings.settings.disk_cache)
	_cache_path = TwitchSettings.get_setting(TwitchSettings.settings.disk_cache_path)
	_chat_timeout_ms = TwitchSettings.get_setting(TwitchSettings.settings.twitch_timeout_ms)
