extends HBoxContainer

class_name ChatMessage 

func set_chatter_msg(badges: String, chatter: Chatter):
	$RichTextLabel.text = "%02d:%02d" %[chatter.date_time_dict["hour"], chatter.date_time_dict["minute"]] + " " + badges + " [b][color="+ chatter.tags.color_hex + "]" +chatter.tags.display_name +"[/color][/b]: " + chatter.message
	
	queue_sort()

