@tool
extends HBoxContainer

func set_chatter_msg(badges: String, chatter: Chatter):
	set_chatter_string("%02d:%02d" %[chatter.date_time_dict["hour"], chatter.date_time_dict["minute"]] + " " + badges + " [b][color="+ chatter.tags.color_hex + "]" +chatter.tags.display_name +"[/color][/b]: " + chatter.message)

func set_chatter_string(message:String):
	$RichTextLabel.text = message
	queue_sort()
