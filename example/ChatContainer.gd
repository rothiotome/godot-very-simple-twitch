extends VBoxContainer

class_name ChatContainer

@onready var scroll_container = $Chat/ScrollContainer
@onready var chat_message_container = $Chat/ScrollContainer/ChatMessageContainer

@onready var twitch_chat = %TwitchChat

func create_chatter_msg(chatter: Chatter):
	var msg_node: ChatMessage = preload("res://example/ChatMessage.tscn").instantiate()
	
	var badges:String = await get_badges(chatter)
	chatter.message = escape_bbcode(chatter.message)
	await add_emotes(chatter)
	
	var bottom: bool = is_scroll_bottom()
	
	msg_node.set_chatter_msg(badges, chatter)
	chat_message_container.add_child(msg_node)
	await get_tree().process_frame
	if bottom: scroll_container.scroll_vertical = scroll_container.get_v_scroll_bar().max_value

func get_badges(chatter: Chatter) -> String:
	var badges:= ""
	for badge in chatter.tags.badges:
		var result = await(twitch_chat.get_badge(badge, chatter.tags.badges[badge], chatter.tags.user_id))
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
	return scroll_container.scroll_vertical == scroll_container.get_v_scroll_bar().max_value - scroll_container.get_v_scroll_bar().get_rect().size.y

# Returns escaped BBCode that won't be parsed by RichTextLabel as tags.
func escape_bbcode(bbcode_text):
	# We only need to replace opening brackets to prevent tags from being parsed.
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
