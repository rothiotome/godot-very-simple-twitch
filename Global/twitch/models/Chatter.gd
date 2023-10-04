extends Resource

class_name Chatter

var login:String
var channel:String
var message:String
var tags:IRCTags

var badges:Dictionary #I want to add the types but GDScript doesn't allow me :(

func is_mod()-> bool:
	return badges.find_key("moderator")

func is_sub()-> bool:
	return badges.find_key("subscriber")

