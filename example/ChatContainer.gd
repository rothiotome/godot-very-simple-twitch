class_name ChatContainer

extends VBoxContainer

var msg_node: PackedScene = preload("res://example/ChatMessage.tscn")
@onready var scroll_container = $Chat/ScrollContainer
@onready var chat_message_container = $Chat/ScrollContainer/ChatMessageContainer

func _ready():
	VerySimpleTwitch.chat_message_received.connect(create_chatter_msg)

func create_chatter_msg(chatter: Chatter):
	var msg: ChatMessage = msg_node.instantiate()

	var badges: String = await get_badges(chatter)
	chatter.message = escape_bbcode(chatter.message)
	await add_emotes(chatter)

	var bottom: bool = is_scroll_bottom()

	msg.set_chatter_msg(badges, chatter)
	chat_message_container.add_child(msg)
	await get_tree().process_frame
	if bottom: scroll_container.scroll_vertical = scroll_container.get_v_scroll_bar().max_value

func get_badges(chatter: Chatter) -> String:
	var badges:= ""
	for badge in chatter.tags.badges:
		var result = await VerySimpleTwitch.get_badge(badge, \
		chatter.tags.badges[badge], chatter.tags.user_id)
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
		var result = await VerySimpleTwitch.get_emote(loc.id)
		var emote_string = "[img=center]" + result.resource_path +"[/img]"
		chatter.message = chatter.message.substr(0, loc.start + offset) + \
		emote_string + chatter.message.substr(loc.end + offset + 1)
		offset += emote_string.length() + loc.start - loc.end - 1

func is_scroll_bottom() -> bool:
	return scroll_container.scroll_vertical == scroll_container.get_v_scroll_bar().max_value -\
	scroll_container.get_v_scroll_bar().get_rect().size.y

# Returns escaped BBCode that won't be parsed by RichTextLabel as tags.
func escape_bbcode(bbcode_text):
	return bbcode_text.replace("[", "[lb]")
