extends HBoxContainer

class_name ChatMessage 

func set_chatter_msg(badges: String, chatter: Chatter):
	$RichTextLabel.text = "%02d:%02d" %[chatter.date_time_dict["hour"], chatter.date_time_dict["minute"]] + " " + badges + " [b][color="+ chatter.tags.color_hex + "]" +chatter.tags.display_name +"[/color][/b]: " + chatter.message
	
	queue_sort()
	
func print_msg():
	pass

func set_stalker_msg(message: String):
	pass
	# $RichTextLabel.text = "%02d:%02d" % [chatter.date_time_dict["hour"], chatter.date_time_dict["minute "]] + "[shake rate=20.0 level=5 connected=1] [b][color=@#FF0000]Stalker[/color][/b]: " + message
	# queue_sort()

