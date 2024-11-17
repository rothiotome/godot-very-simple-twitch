extends GutTest


func test_get_random_name_color():
	var color_rothio_a:Color = VSTUtils.get_random_name_color("Rothio", 0)
	var color_rothio_b:Color = VSTUtils.get_random_name_color("Rothio", 0)
	assert_not_null(color_rothio_a)
	assert_not_null(color_rothio_b)
	assert_eq(color_rothio_a, color_rothio_b)
	var color_rothio_c:Color = VSTUtils.get_random_name_color("Rothio", 1)
	assert_not_same(color_rothio_a, color_rothio_c)
	assert_not_same(color_rothio_b, color_rothio_c)


func test_normalize_color():
	var color_dark = Color.BLACK
	var color_dark_normalized = VSTUtils.normalize_color(color_dark)
	var color_light = Color.WHITE
	var color_light_normalized = VSTUtils.normalize_color(color_light)
	var color_normal = Color.LIGHT_CORAL
	var color_normal_normalized = VSTUtils.normalize_color(color_normal)
	assert_eq(color_normal_normalized, Color.LIGHT_CORAL)
	assert_eq(color_light_normalized, Color(0.8, 0.8, 0.8, 1))
	assert_eq(color_dark_normalized, Color(0.2, 0.2, 0.2, 1))


func test_normalize_color_str():
	var color_dark = Color.BLACK
	var color_dark_normalized = VSTUtils.normalize_hex_color(color_dark.to_html())
	var color_light = Color.WHITE
	var color_light_normalized = VSTUtils.normalize_hex_color(color_light.to_html())
	var color_normal = Color.LIGHT_CORAL
	var color_normal_normalized = VSTUtils.normalize_hex_color(color_normal.to_html())
	assert_eq(color_normal_normalized, Color.LIGHT_CORAL)
	assert_eq(color_light_normalized, Color(0.8, 0.8, 0.8, 1))
	assert_eq(color_dark_normalized, Color(0.2, 0.2, 0.2, 1))
