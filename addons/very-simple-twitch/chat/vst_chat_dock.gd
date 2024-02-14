@tool
extends Control

const MAX_MESSAGES:int = 50
var line:PackedScene = load("res://addons/very-simple-twitch/chat/vst_chat_dock_line.tscn")

var twitch_chat: TwitchChat:
	get:
		if twitch_chat == null:
			twitch_chat = TwitchChat.new()
			add_child(twitch_chat)
		return twitch_chat

var channel_line_edit: LineEdit:
	get:
		if channel_line_edit == null:
			channel_line_edit = $VBoxContainer/HBoxContainer/LineEdit
		return channel_line_edit

var connect_button: Button:
	get:
		if connect_button == null:
			connect_button = $VBoxContainer/HBoxContainer/ConnectButton
		return connect_button
	
var chat_layout: Control:
	get:
		if chat_layout == null:
			chat_layout = $VBoxContainer/VBoxContainer/Chat/ScrollContainer/ChatMessageContainer
		return chat_layout
	
var chat_scroll:ScrollContainer:
	get:
		if chat_scroll == null:
			chat_scroll = $VBoxContainer/VBoxContainer/Chat/ScrollContainer
		return chat_scroll

var clear_button:Button:
	get:
		if clear_button == null:
			clear_button = $VBoxContainer/HBoxContainer/ClearButton
		return clear_button

var disconnect_button:Button:
	get:
		if disconnect_button == null:
			disconnect_button = $VBoxContainer/HBoxContainer/DisconnectButton
		return disconnect_button
	
func _on_button_pressed():
	twitch_chat.OnSucess.connect(onChatConnected)
	twitch_chat.OnMessage.connect(create_chatter_msg)
	twitch_chat.OnFailure.connect(onError)
	
	twitch_chat.login_anon(channel_line_edit.text)
	connect_button.disabled = true
	channel_line_edit.editable = false

func _on_line_edit_text_changed(new_text):
	connect_button.disabled = len(new_text) == 0

func onChatConnected():
	create_system_msg("Connected to Chat")
	show_chat_layout()

func onError():
	create_system_msg("Failed to connect into chat")
	connect_button.disabled = false
	channel_line_edit.editable = true

func create_system_msg(message: String):
	var msg = line.instantiate()
	msg.set_chatter_string("[i]"+message+"[/i]")
	chat_layout.add_child(msg)
	check_scroll()


func create_chatter_msg(chatter: Chatter):
	var msg = line.instantiate()
	
	var badges: String = await get_badges(chatter)
	chatter.message = escape_bbcode(chatter.message)
	await add_emotes(chatter)

	msg.set_chatter_msg(badges, chatter)
	chat_layout.add_child(msg)
	
	check_scroll()

func check_scroll():
	var bottom: bool = is_scroll_bottom()
	check_number_messages()
	await get_tree().process_frame
	if bottom: chat_scroll.scroll_vertical = chat_scroll.get_v_scroll_bar().max_value

func check_number_messages():
	if chat_layout.get_child_count() > MAX_MESSAGES:
		chat_layout.remove_child(chat_layout.get_children()[0])

func get_badges(chatter: Chatter) -> String:
	var badges:= ""
	for badge in chatter.tags.badges:
		var result = await twitch_chat.get_badge(badge, chatter.tags.badges[badge], chatter.tags.user_id) 
		if result:
			badges += "[img=center]" + result.resource_path + "[/img] "
	return badges
	
func add_emotes(chatter: Chatter):
	if chatter.tags.emotes.is_empty(): return

	var locations: Array = []
	for emote in chatter.tags.emotes:
		for data in chatter.tags.emotes[emote].split(","):
			var start_end = data.split("-")
			locations.append(EmoteLocation.new(emote, int(start_end[0]), int(start_end[1])))

	locations.sort_custom(Callable(EmoteLocation, "smaller"))
	var offset = 0
	for loc in locations:
		var result = await twitch_chat.get_emote(loc.id)
		var emote_string = "[img=center]" + result.resource_path +"[/img]"
		chatter.message = chatter.message.substr(0, loc.start + offset) + emote_string + chatter.message.substr(loc.end + offset + 1)
		offset += emote_string.length() + loc.start - loc.end - 1
	
func is_scroll_bottom() -> bool:
	return chat_scroll.scroll_vertical == chat_scroll.get_v_scroll_bar().max_value - chat_scroll.get_v_scroll_bar().get_rect().size.y

# Returns escaped BBCode that won't be parsed by RichTextLabel as tags.
func escape_bbcode(bbcode_text) -> String:
	return bbcode_text.replace("[", "[lb]")

class EmoteLocation extends RefCounted:
	var id : String
	var start : int
	var end : int

	func _init(emote_id, start_idx, end_idx):
		self.id = emote_id
		self.start = start_idx
		self.end = end_idx

	static func smaller(a: EmoteLocation, b: EmoteLocation):
		return a.start < b.start


func _on_clear_button_pressed():
	clear_all_messages()

func clear_all_messages():
	for childen in chat_layout.get_children():
		chat_layout.remove_child(childen)

func _on_disconnect_button_pressed():
	# TODO: Ok, It's too much removing the node and placing another. Change it when logout method is available
	twitch_chat.queue_free()
	twitch_chat = null
	
	clear_all_messages()
	show_connect_layout()

func show_chat_layout():
	disconnect_button.visible = true
	clear_button.visible = true
	channel_line_edit.visible = false
	connect_button.visible = false
	
func show_connect_layout():
	disconnect_button.visible = false
	clear_button.visible = false
	channel_line_edit.editable = true
	channel_line_edit.visible = true
	connect_button.visible = true
	connect_button.disabled = false
	
