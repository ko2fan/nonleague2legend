class_name Utils

static func CommaNumber(value : int) -> String:
	var ret_string = str(value)
	var number_of_letters = ret_string.length()
	var reverse_i = number_of_letters - 1
	for i in number_of_letters - 1:
		if i == 0:
			continue
		if i % 3 == 0:
			ret_string = ret_string.insert(reverse_i, ",")
		reverse_i -= 1
			
	return ret_string
