class_name TwitchParseHelper

static func parse_login(input_string:String) -> String:
	return get_substring(input_string, ":", "!")


static func parse_channel(input_string:String) -> String:
	return input_string.trim_prefix("#")


static func parse_message(input_string:String) -> String:
	return input_string.trim_prefix(":").strip_edges()


static func parse_tags(input_string:String) -> IRCTags:
	var irc_tags = IRCTags.new()
	var tags:PackedStringArray = input_string.split(";")
	
	for i in len(tags):
		var splitted_tag:PackedStringArray = tags[i].split("=")
		
		if splitted_tag.size() <= 1: continue
		
		match(splitted_tag[0]):
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


static func parse_badges(input:PackedStringArray) -> Dictionary:
	var badges: Dictionary = {}
	if input.is_empty() || input[0].is_empty(): return badges
	
	for i in len(input):
		var substrings = input[i].split("/")
		badges[substrings[0]] = substrings[1]
	return badges


static func parse_emotes(input:PackedStringArray) -> Dictionary:
	var emotes: Dictionary = {}
	if input.is_empty() || input[0].is_empty(): return emotes
	for emote in input:
		var substring: PackedStringArray = emote.split(":")
		emotes[substring[0]] = substring[1]
	return emotes


static func get_substring(input_string:String, starting_char:String, ending_char:String) -> String:
	var first_index = input_string.find(starting_char)
	var last_index = input_string.find(ending_char)

	# Extract the substring between ':' and '!'
	return input_string.substr(first_index + 1, last_index - first_index - 1)
