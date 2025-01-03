class_name VSTEmoteLocation

extends RefCounted

var id : String
var start : int
var end : int

func _init(emote_id, start_idx, end_idx):
	self.id = emote_id
	self.start = start_idx
	self.end = end_idx

static func smaller(a: VSTEmoteLocation, b: VSTEmoteLocation):
	return a.start < b.start
