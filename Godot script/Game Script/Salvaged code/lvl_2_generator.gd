extends Control

@onready var problem_label: Label = $ProblemLabel

var variables = ["x", "y"]
var inequality_signs = ["<", ">"]

var current_problem: String
var current_answer: String

func _ready():
	randomize()
	generate_problem()

func random_number(minimum: int, maximum: int, allow_negative: bool = false) -> int:
	var num = 0
	while num == 0:
		num = randi() % (maximum - minimum + 1) + minimum
		if allow_negative and randi() % 2 == 0:
			num = -num
	return num

func random_variable() -> String:
	return variables[randi() % variables.size()]

func random_inequality() -> String:
	return inequality_signs[randi() % inequality_signs.size()]

func generate_problem():
	var problem_type = random_number(1, 5)
	var variable = random_variable()
	print(problem_type)
	match problem_type:
		1:
			var sol = random_number(-8, 8, true)
			var a = random_number(2, 6, true)
			var b = random_number(-5, 5, true)
			var c = random_number(-8, 8, true)
			var rhs = a * (sol + b) + c
			current_problem = "%d(%s + %d) + %d = %d, %s = ?" % [a, variable, b, c, rhs, variable]
			current_answer = "%d" % [sol]

		2:
			var sol = random_number(-7, 7, true)
			var a = random_number(2, 5, true)
			var b = random_number(2, 5, true)
			while a == b:
				b = random_number(2, 5, true)
			var c = random_number(-6, 6, true)
			var d = a * sol + c - b * sol
			current_problem = "%d%s + %d = %d%s + %d, %s = ?" % [a, variable, c, b, variable, d, variable]
			current_answer = "%d" % [sol]

		3:
			var sol = random_number(-6, 6, true)
			var a = random_number(2, 8, false)
			var b = random_number(1, 10, true)
			var sign_ = random_inequality()
			var rhs = a * sol + b
			var b_term = "%s %d" % [("+" if b >= 0 else "-"), abs(b)]
			current_problem = "Solve: %d%s %s %s %d" % [a, variable, b_term, sign_, rhs]
			current_answer = "%s%s%d" % [variable, sign_, sol]

		4:
			var sol = random_number(-6, 6, true)
			var a = random_number(-8, -2)  # Always negative
			var b = random_number(-10, 10, true)
			var sign_ = random_inequality()

			var lhs = a * sol + b
			var rhs = lhs  # Construct RHS so that x = sol is the true solution

			var answer_val = sol

			match sign_:
				">":
					# For a*x + b > rhs, since a is negative:
					# x < (rhs - b)/a → x < sol (sign flips)
					current_problem = "Solve: %d%s + %d > %d" % [a, variable, b, rhs]
					current_answer = "%s<%d" % [variable, answer_val]
					
				"<":
					# For a*x + b < rhs, since a is negative:
					# x > (rhs - b)/a → x > sol (sign flips)
					current_problem = "Solve: %d%s + %d < %d" % [a, variable, b, rhs]
					current_answer = "%s>%d" % [variable, answer_val]

		5:
			# Generate solution (-10 to 10, non-zero)
			var sol = random_number(-10, 10, true)
			while sol == 0:
				sol = random_number(-6, 6, true)
			
			# Generate a ≠ c
			var a = random_number(2, 6)
			var c = random_number(2, 6)
			while a == c:
				c = random_number(2, 6)
				
			# We need to find integer values of b and d such that:
			# a(sol+b) = c(sol+d)
			# Rearranging:
			# a*sol + a*b = c*sol + c*d
			# c*d = a*sol + a*b - c*sol
			# c*d = a*b + sol*(a-c)
			# d = (a*b + sol*(a-c))/c
			
			# We'll try different values of b until we find one that gives an integer d
			var max_attempts = 20  # Prevent infinite loops
			var attempts = 0
			var b = 0
			var d = 0
			var valid_equation = false
			
			while not valid_equation and attempts < max_attempts:
				b = random_number(-4, 4, true)
				
				# Calculate needed value for d
				var numerator = a*b + sol*(a-c)
				
				# Check if this will give an integer d (divisible by c)
				if numerator % c == 0:
					@warning_ignore("integer_division")
					d = numerator / c  # This will be clean integer division
					
					# Check if d is in range [-4, 4]
					if d >= -4 and d <= 4:
						# Verify equation holds: a(sol+b) = c(sol+d)
						if a * (sol + b) == c * (sol + d):
							# Double-check solution
							# If a(sol+b) = c(sol+d), then
							# a*sol + a*b = c*sol + c*d
							# a*sol - c*sol = c*d - a*b
							# sol*(a-c) = c*d - a*b
							# sol = (c*d - a*b)/(a-c)
							
							# The division must yield exactly our solution
							@warning_ignore("integer_division")
							if (c*d - a*b) % (a-c) == 0 and (c*d - a*b) / (a-c) == sol:
								valid_equation = true
				
				attempts += 1
			
			# If we couldn't find a valid combination after max attempts, restart with new a, c, sol
			if not valid_equation:
				return generate_problem()  # Recursive call
			
			# Format the problem
			var b_str = "+ %d" % b if b >= 0 else "- %d" % -b
			var d_str = "+ %d" % d if d >= 0 else "- %d" % -d
			current_problem = "%d(%s %s) = %d(%s %s), %s = ?" % [a, variable, b_str, c, variable, d_str, variable]
			current_answer = "%d" % [sol] 

	problem_label.text = current_problem
	
	
func get_current_answer() -> String:
	return current_answer
