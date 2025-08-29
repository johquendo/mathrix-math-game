extends Control

@onready var problem_label: Label = $ProblemLabel

# Variable letters and operators to choose from
var variables = ["x", "y"]
var operators = ["+", "-"]

# Tracks the current problem and its correct answer
var current_problem: String
var current_answer: String

func _ready():
	randomize()
	generate_problem()

# Returns a random number in the given range, excluding zero
func random_number_exclude_zero(minimum, maximum):
	var num = 0
	while num == 0:
		num = randi() % (maximum - minimum + 1) + minimum
	return num

# Returns a random variable (x or y)
func random_variable():
	return variables[randi() % variables.size()]

# Returns a random operator (+ or -)
func random_operator():
	return operators[randi() % operators.size()]

# Formats a term like 3x, -x, or just x
func format_term(coefficient: int, variable: String) -> String:
	if coefficient == 1:
		return variable
	elif coefficient == -1:
		return "-" + variable
	else:
		return str(coefficient) + variable

# Main problem generator
func generate_problem():
	var topic_type = randi() % 3 + 1  # Choose topic 1, 2, or 3
	var variable = random_variable()

	match topic_type:
		### 1. Simplifying Expressions
		1:
			var mode = randi() % 2 + 1  # 1 = basic simplify, 2 = distributive
			if mode == 1:
				# Example: 3x - 2x
				var c1 = random_number_exclude_zero(-10, 10)
				var c2 = random_number_exclude_zero(-10, 10)
				var result = c1 + c2
				while result == 0:
					c1 = random_number_exclude_zero(-10, 10)
					c2 = random_number_exclude_zero(-10, 10)
					result = c1 + c2

				current_problem = "%s %s %s" % [
					format_term(c1, variable),
					"+" if c2 >= 0 else "-",
					format_term(abs(c2), variable)
				]
				current_answer = format_term(result, variable)

			else:
				# Distribute: a(bx + c)
				var a = random_number_exclude_zero(-10, 10)
				var b = random_number_exclude_zero(-10, 10)
				var c = random_number_exclude_zero(-10, 10)

				var term_inside = "%s%s %s %d" % [
					"" if b == 1 else str(b),
					variable,
					"+" if c >= 0 else "-",
					abs(c)
				]
				current_problem = "Distribute: %d(%s)" % [a, term_inside]

				var final_coeff = a * b
				var final_const = a * c

				current_answer = ""
				if final_coeff != 0:
					current_answer += format_term(final_coeff, variable)
				if final_const > 0:
					current_answer += "+%d" % final_const
				elif final_const < 0:
					current_answer += "%d" % final_const

		### 2. One-step Equation
		2:
			var solution = random_number_exclude_zero(-10, 10)
			var op = random_operator()
			var coeff = random_number_exclude_zero(3, 10)

			if op == "+":
				var rhs = solution + coeff
				current_problem = "%s + %d = %d, %s = ?" % [variable, coeff, rhs, variable]
				current_answer = "%d" % [solution]
			else:
				var lhs = coeff * solution
				current_problem = "%d%s = %d, %s = ?" % [coeff, variable, lhs, variable]
				current_answer = "%d" % [solution]

		### 3. Evaluating an Expression
		3:
			var value = random_number_exclude_zero(-5, 10)
			var coeff = random_number_exclude_zero(1, 10)
			var constant = random_number_exclude_zero(-10, 10)

			current_problem = "Evaluate: %d%s %s %d for %s = %d" % [
				coeff,
				variable,
				"+" if constant > 0 else "-",
				abs(constant),
				variable,
				value
			]
			current_answer = str(coeff * value + constant)

	# Display to UI
	problem_label.text = current_problem

# Getter for external checking
func get_current_answer() -> String:
	return current_answer
