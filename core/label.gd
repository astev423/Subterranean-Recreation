extends Label

func _process(_delta: float) -> void:
	var viewport_rid := get_viewport().get_viewport_rid()

	var visible_primitives := RenderingServer.viewport_get_render_info(
		viewport_rid,
		RenderingServer.VIEWPORT_RENDER_INFO_TYPE_VISIBLE,
		RenderingServer.VIEWPORT_RENDER_INFO_PRIMITIVES_IN_FRAME
	)

	text = "Visible triangles: %s" % format_with_commas(visible_primitives)


func format_with_commas(value: int) -> String:
	var s := str(abs(value))
	var result := ""
	var count := 0

	for i in range(s.length() - 1, -1, -1):
		result = s.substr(i, 1) + result
		count += 1

		if count % 3 == 0 and i != 0:
			result = "," + result

	if value < 0:
		result = "-" + result

	return result