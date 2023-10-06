extends Resource

class_name Chatter

var login:String
var channel:String
var message:String
var tags:IRCTags

func is_mod()-> bool:
	return tags.badges.find_key("moderator")

func is_sub()-> bool:
	return tags.badges.find_key("subscriber")

