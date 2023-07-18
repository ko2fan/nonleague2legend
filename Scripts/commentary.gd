extends ScrollContainer

@onready var scrollbar = get_v_scroll_bar()

var max_scroll_length = 0 

func _ready(): 
	scrollbar.changed.connect(_handle_scrollbar_changed)
	max_scroll_length = scrollbar.max_value

func _handle_scrollbar_changed(): 
	if max_scroll_length != scrollbar.max_value: 
		max_scroll_length = scrollbar.max_value 
	self.scroll_vertical = max_scroll_length
