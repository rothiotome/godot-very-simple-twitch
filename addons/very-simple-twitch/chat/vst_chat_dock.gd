@tool
extends Control

const MAX_MESSAGES:int = 50
var line: PackedScene = load("res://addons/very-simple-twitch/chat/vst_chat_dock_line.tscn")


var twitch_chat: VSTChat:
	get:
		if twitch_chat == null:
			twitch_chat = VSTChat.new()
			add_child(twitch_chat)
		return twitch_chat

@onready var support_button: Button = %SupportButton
@onready var channel_line_edit: LineEdit = %ChannelLineEdit

@onready var connect_button: Button = %ConnectButton

@onready var chat_layout: Control = %ChatLayout

@onready var chat_scroll:ScrollContainer = %ChatScroll

@onready var clear_button:Button = %ClearButton

@onready var disconnect_button:Button = %DisconnectButton

func _ready():
	support_button.icon = get_theme_icon("Heart", "EditorIcons")
	support_button.tooltip_text = "Support me on Ko-fi"

func _on_button_pressed():
	twitch_chat.Connected.connect(on_chat_connected)
	twitch_chat.OnMessage.connect(create_chatter_msg)

	twitch_chat.login_anon(channel_line_edit.text)
	connect_button.disabled = true
	channel_line_edit.editable = false

func _on_clear_button_pressed():
	clear_all_messages()

func _on_line_edit_text_changed(new_text):
	connect_button.disabled = len(new_text) == 0

func _on_disconnect_button_pressed():
	twitch_chat.disconnect_api()
	clear_all_messages()
	show_connect_layout()
	if twitch_chat.Connected.is_connected(on_chat_connected):
		twitch_chat.Connected.disconnect(on_chat_connected)
	if twitch_chat.OnMessage.is_connected(create_chatter_msg):
		twitch_chat.OnMessage.disconnect(create_chatter_msg)


func _on_support_button_pressed() -> void:
	OS.shell_open("https://ko-fi.com/rothiotome?ref=VST")


func on_chat_connected():
	create_system_msg("Connected to chat")
	show_chat_layout()

func create_system_msg(message: String):
	var msg = line.instantiate()
	msg.set_chatter_string("[i]"+message+"[/i]")
	chat_layout.add_child(msg)
	check_scroll()

func create_chatter_msg(chatter: VSTChatter):
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

# TODO: Can't get badges when the connection is annonymous, we should clear this method
func get_badges(chatter: VSTChatter) -> String:
	var badges:= ""
	for badge in chatter.tags.badges:
		var result = await twitch_chat.get_badge(badge, chatter.tags.badges[badge], chatter.tags.user_id)
		if result:
			badges += "[img=center]" + result.resource_path + "[/img] "
	return badges

func add_emotes(chatter: VSTChatter):
	if chatter.tags.emotes.is_empty(): return

	var locations: Array = []
	for emote in chatter.tags.emotes:
		for data in chatter.tags.emotes[emote].split(","):
			var start_end = data.split("-")
			locations.append(VSTEmoteLocation.new(emote, int(start_end[0]), int(start_end[1])))

	locations.sort_custom(Callable(VSTEmoteLocation, "smaller"))
	var offset = 0
	for loc in locations:
		var result = await twitch_chat.get_emote(loc.id)
		var emote_string = "[img=center]" + result.resource_path +"[/img]"
		var pre: String = chatter.message.substr(0, loc.start + offset)
		var post: String = chatter.message.substr(loc.end + offset + 1)
		chatter.message = pre + emote_string + post
		offset += emote_string.length() + loc.start - loc.end - 1

func is_scroll_bottom() -> bool:
	var scroll_bar = chat_scroll.get_v_scroll_bar()
	return chat_scroll.scroll_vertical >= scroll_bar.max_value - scroll_bar.get_rect().size.y


# Returns escaped BBCode that won't be parsed by RichTextLabel as tags.
func escape_bbcode(bbcode_text) -> String:
	return bbcode_text.replace("[", "[lb]")

func clear_all_messages():
	for childen in chat_layout.get_children():
		chat_layout.remove_child(childen)

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
