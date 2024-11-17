class_name VSTParseHelper

# Parse login name from payload substring of twitch irc chat
static func parse_login(input_string:String) -> String:
	return get_substring(input_string, ":", "!")


# Parse channel name from payload substring of twitch irc chat
static func parse_channel(input_string:String) -> String:
	return input_string.trim_prefix("#")


# Parse message from payload substring of twitch irc chat
static func parse_message(input_string:String) -> String:
	return input_string.trim_prefix(":").strip_edges()


static func parse_tags(input_string:String) -> VSTIRCTags:
	var irc_tags = VSTIRCTags.new()
	var tags:PackedStringArray = input_string.split(";")

	for i in len(tags):
		var splitted_tag:PackedStringArray = tags[i].split("=")

		if splitted_tag.size() <= 1: continue

		match(splitted_tag[0].strip_edges()):
			"badges":
				irc_tags.badges = parse_badges(splitted_tag[1].split(","))
			"color":
				irc_tags.color_hex = splitted_tag[1]
			"display-name":
				irc_tags.display_name = splitted_tag[1]
			"emotes":
				irc_tags.emotes = parse_emotes(splitted_tag[1].split("/"))
			"room-id":
				irc_tags.user_id = splitted_tag[1]

	return irc_tags


# Parse badges from payload substring of twitch irc chat. Returns a dictionary with the badge itself
# and the position of the badge
static func parse_badges(input:PackedStringArray) -> Dictionary:
	var badges: Dictionary = {}
	if input.is_empty() || input[0].is_empty(): return badges

	for i in len(input):
		var substrings = input[i].split("/")
		if len(substrings) > 1:
			badges[substrings[0]] = substrings[1]
	return badges


# Parse emotes from payload substring of twitch irc chat. Returns a dictionary with the emote
# itself and the position in the user message in order to replace the text with the image emote
static func parse_emotes(input:PackedStringArray) -> Dictionary:
	var emotes: Dictionary = {}
	if input.is_empty() || input[0].is_empty(): return emotes
	for emote in input:
		var substring: PackedStringArray = emote.split(":")
		if len(substring) > 1:
			emotes[substring[0]] = substring[1]
	return emotes



static func get_substring(input_string:String, starting_char:String, ending_char:String) -> String:
	var first_index = input_string.find(starting_char)
	var last_index = input_string.find(ending_char)

	if first_index == -1 or last_index == -1 or last_index < first_index:
		return input_string
	return input_string.substr(first_index + 1, last_index - first_index - 1)
