extends Sprite2D  # Can also use TextureRect for UI elements

# Floating animation parameters
@export var float_height: float = 10.0  # How high it floats
@export var float_speed: float = 2.0    # Speed of floating
@export var rotate_speed: float = 0.5   # Rotation speed (0 for no rotation)

var original_position: Vector2
var time: float = 0.0

func _ready():
	# Store the original position
	original_position = position
	
	# Optional: Enable processing
	set_process(true)

func _process(delta):
	time += delta
	
	# Calculate floating offset using sine wave for smooth motion
	var vertical_offset = sin(time * float_speed) * float_height
	
	# Update position with floating effect
	position.y = original_position.y + vertical_offset
	
	# Optional rotation effect
	if rotate_speed > 0:
		rotation = sin(time * rotate_speed * 0.5) * 0.1  # Small rotation
