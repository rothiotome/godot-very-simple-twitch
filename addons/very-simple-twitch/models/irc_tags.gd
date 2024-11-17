class_name VSTIRCTags

# Model for a IRC twitch chat
var color_hex: String # color of user used in twtich chat
var display_name: String # name of a user
var channel_id: String # not used
var user_id: String # numeric id of the user used in twitch

var badges: Dictionary # badges of the user in message
var emotes: Dictionary # emotes writed by user in message

func _to_string():
	return "color_hex: %s, display_name: %s, channel_id: %s, user_id: %s, badges: %s, emotes: %s" % [color_hex, display_name, str(channel_id), str(user_id), badges, emotes]
