extends Node

class_name TwitchChat

signal OnSucess
signal OnMessage(chatter:Chatter)
signal OnFailure(reason:String)

var _channel:TwitchChannel

var _chatClient:WebSocketPeer
var _hasConnected:bool = false

func _process(_delta:float):
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
		WebSocketPeer.STATE_CLOSED:
			if _hasConnected:
				_hasConnected = false
				var code = _chatClient.get_close_code()
				var reason = _chatClient.get_close_reason()
				print('Disconnected from twitch chat')
				print("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
				print("Reconnecting")
				start_chat_client(_channel)

func start_chat_client(channel:TwitchChannel):
	_channel = channel
	if _chatClient:
		_chatClient.close()
	_chatClient = WebSocketPeer.new()
	_chatClient.connect_to_url("%s:%d" % [TwitchChatSettings.TWITCH_CHAT_WS_URL, TwitchChatSettings.TWITCH_PORT])

func onChatConnected():
	if !_channel:
		return
	_hasConnected = true
	_chatClient.send_text("CAP REQ :twitch.tv/tags twitch.tv/commands")
	_chatClient.send_text('PASS oauth:' + _channel.token)
	_chatClient.send_text('NICK ' + _channel.login.to_lower())
	_chatClient.send_text('JOIN ' + '#' + _channel.login.to_lower())
	OnSucess.emit()

func onReceivedData(payload: PackedByteArray):
	var message = payload.get_string_from_utf8()
	handle_message(message)

func send(message):
	pass
		
func handle_message(message:String):
	if message.begins_with("PING"):
		send(message.replace("PING", "PONG"))
		#pong.emit()
		return

	var parsed_message:PackedStringArray = message.split(" ", true, 4) # We might need more than 3

# 0 -> BADGES
# 1 -> login
# 2 -> TAG
# 3 -> name con el hashtag
# Después es el mensaje (hay que quitarle los dos puntos)
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
			#login_attempt.emit(true)
		"PRIVMSG":
			handle_privmsg(parsed_message)
			#handle_command(sender_data, msg[3].split(" ", true, 1))
			#chat_message.emit(sender_data, msg[3].right(-1))

func handle_privmsg(msg:PackedStringArray):
		
	var chatter = Chatter.new()
	chatter.login = Utils.parse_login(msg[1])
	chatter.channel = Utils.parse_channel(msg[3])
	chatter.message = Utils.parse_message(msg[4])
	chatter.tags = Utils.parse_tags(msg[0])
	
	print("login: "+ chatter.login)
	print("channel: "+ chatter.channel)
	print("message: "+ chatter.message)
	print("color_hex: "+ chatter.tags.color_hex)
	print("display_name: "+ chatter.tags.display_name)
	#:ytgard!ytgard@ytgard.tmi.twitch.tv
