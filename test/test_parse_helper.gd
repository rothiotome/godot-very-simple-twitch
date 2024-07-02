extends GutTest

func test_parse_login():
	# Parse a good substring from a real payload
	var result = TwitchParseHelper.parse_login(":rothio!rothio@rothio.tmi.twitch.tv")
	assert_eq(result, "rothio")
	result = TwitchParseHelper.parse_login(":rothiotome!rothiotome@rothiotome.tmi.twitch.tv")
	assert_eq(result, "rothiotome")

	# Not parsing a wrong substring
	result = TwitchParseHelper.parse_login("bad_login_rothiotome")
	assert_eq(result, "bad_login_rothiotome")


func test_parse_channel():
	# Parse a good substring from a real payload
	var result = TwitchParseHelper.parse_channel("#rothio")
	assert_eq(result, "rothio")

	# Not parsing a wrong substring from payload
	result = TwitchParseHelper.parse_channel("_rothio_bad_channel")
	assert_eq(result, "_rothio_bad_channel")


func test_parse_message():
	# Parse a good substring from a real payload
	var result = TwitchParseHelper.parse_message(":rothioCuchillo rothioJeje")
	assert_eq(result, "rothioCuchillo rothioJeje")
	result = TwitchParseHelper.parse_message(":  rothioCuchillo rothioJeje  ")
	assert_eq(result, "rothioCuchillo rothioJeje")

	# Not parsing a wrong substring from payload
	result = TwitchParseHelper.parse_message("_rothioCuchillo rothioJeje")
	assert_eq(result, "_rothioCuchillo rothioJeje")


func test_parse_tags():
	var result:IRCTags = TwitchParseHelper.parse_tags(\
	"@badge-info=subscriber/21;badges=broadcaster/1,subscriber/0;client-nonce=1f0134354;\
	color=#FF666F;display-name=RothioTome;emote-only=1;emotes=emotesv2_3328e0d6b6714a6a90dc8f58d09e5648:11-24/\
	emotesv2_4b9a9537c7e34c3395ada46471c4097e:26-35;first-msg=0;flags=;id=6da896da-f543-4928-b5b0-ad84f216a0e3;\
	mod=0;returning-chatter=0;room-id=156108906;subscriber=1;tmi-sent-ts=1;turbo=0;user-id=1;user-type=")
	assert_eq(result.user_id, "156108906")
	assert_eq(result.color_hex, "#FF666F")
	assert_eq(result.display_name, "RothioTome")
	var parsed_badges = {"broadcaster": "1", "subscriber": "0"}
	assert_eq_deep(result.badges, parsed_badges)
	var parsed_emotes = { "emotesv2_3328e0d6b6714a6a90dc8f58d09e5648": "11-24", 
	"emotesv2_4b9a9537c7e34c3395ada46471c4097e": "26-35" }
	assert_eq_deep(result.emotes, parsed_emotes)


func test_parse_badges():
	var array:PackedStringArray = ["verified/2", "broadcaster/1", "subscriber/0"]
	var parsed = {"verified": "2", "broadcaster": "1", "subscriber": "0"}

	# Parse an array with a good badge format
	var result = TwitchParseHelper.parse_badges(array)
	assert_eq_deep(result, parsed)
	
	# Parse an array with some bad badge format
	array = ["a", "verified/2", "b", "broadcaster/1", "subscriber/0"]
	result = TwitchParseHelper.parse_badges(array)
	assert_eq_deep(result, parsed)

	# Parse an empty array of badges
	result = TwitchParseHelper.parse_badges([])
	assert_eq_deep(result, {})


func test_parse_emotes():
	var array:PackedStringArray = ["emotesv2_3328e0d6b6714a6a90dc8f58d09e5648:11-24", 
	"emotesv2_4b9a9537c7e34c3395ada46471c4097e:26-35"]
	var parsed = { "emotesv2_3328e0d6b6714a6a90dc8f58d09e5648": "11-24", 
	"emotesv2_4b9a9537c7e34c3395ada46471c4097e": "26-35" }

	# Parse an array with a good emote format
	var result = TwitchParseHelper.parse_emotes(array)
	assert_eq_deep(result, parsed)

	# Parse an empty emote array
	result = TwitchParseHelper.parse_emotes([])
	assert_eq_deep(result,{})

	# Parse an array with a wrong emote format
	array = ["emotesv2_3328e0d6b6714a6a90dc8f58d09e5648:11-24", 
	"emotesv2_4b9a9537c7e34c3395ada46471c4097e:26-35", "a", "b"]
	result = TwitchParseHelper.parse_emotes(array)
	assert_eq_deep(result, parsed)


func test_parse_substring():
	# Returning expected value from char to char substring
	var result = TwitchParseHelper.get_substring(":abc!",":","!")
	assert_eq(result, "abc")
	result = TwitchParseHelper.get_substring("abcdef","b","f")
	assert_eq(result, "cde")
	result = TwitchParseHelper.get_substring(":abc!","!","!")
	assert_eq(result, "")

	# Returning the same value from a invalid or not found chars
	result = TwitchParseHelper.get_substring(":abc!","x","!")
	assert_eq(result, ":abc!")
	result = TwitchParseHelper.get_substring(":abc!","!","x")
	assert_eq(result, ":abc!")
	result = TwitchParseHelper.get_substring(":abc!","c","a")
	assert_eq(result, ":abc!")
