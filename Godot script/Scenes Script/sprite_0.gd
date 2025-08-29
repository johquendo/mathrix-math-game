extends Sprite2D  # Can also use TextureRect for UI elements

# Floating animation parameters
@export var float_height: float = 10.0  # How high it floats
@export var float_speed: float = 2.0    # Speed of floating
@export var rotate_speed: float = 0.5   # Rotation speed (0 for no rotation)

# Spinning animation parameters
@export var spin_enabled: bool = true   # Toggle spinning on/off
@export var spin_speed: float = 1.0     # Speed of spinning rotation
@export var spin_direction: int = 1     # 1 for clockwise, -1 for counterclockwise
@export var spin_axis: Vector3 = Vector3(0, 1, 0)  # Axis to spin around (for 3D feel)

var original_position: Vector2
var original_rotation: float
var time: float = 0.0

func _ready():
	# Store the original position and rotation
	original_position = position
	original_rotation = rotation
	
	# Optional: Enable processing
	set_process(true)

func _process(delta):
	time += delta
	
	# Calculate floating offset using sine wave for smooth motion
	var vertical_offset = sin(time * float_speed) * float_height
	
	# Update position with floating effect
	position.y = original_position.y + vertical_offset
	
	# Optional gentle rocking rotation
	if rotate_speed > 0:
		rotation = original_rotation + sin(time * rotate_speed * 0.5) * 0.1  # Small rotation
	
	# Spinning animation - continuous rotation
	if spin_enabled:
		apply_spin_animation(delta)

func apply_spin_animation(delta):
	# Continuous spinning rotation
	rotation += spin_speed * spin_direction * delta
	
	# Optional: Add some 3D-like perspective effect to the spin
	if spin_axis != Vector3(0, 1, 0):
		# For more complex 3D-like spinning effects
		apply_3d_spin_effect(delta)

func apply_3d_spin_effect(delta):
	# Simulate 3D spinning by modifying scale and skew
	var spin_progress = time * spin_speed
	var scale_variation = 0.9 + 0.1 * abs(sin(spin_progress))
	
	# Adjust scale based on spin progress for pseudo-3D effect
	scale = Vector2(scale_variation, scale_variation)
	
	# Optional: Add slight skew for more dynamic spin
	if spin_axis.x > 0:
		var skew_amount = sin(spin_progress) * 0.1
		# Note: Godot 4 doesn't have direct skew property for Sprite2D,
		# but you can use a shader or create a custom material for this effect

# Public functions to control spinning
func start_spinning():
	spin_enabled = true

func stop_spinning():
	spin_enabled = false

func set_spin_speed(new_speed: float):
	spin_speed = new_speed

func reverse_spin_direction():
	spin_direction *= -1

func reset_spin():
	rotation = original_rotation
	scale = Vector2(1, 1)

# Optional: Add some randomness to the spin
func add_spin_randomness():
	spin_speed *= randf_range(0.8, 1.2)
	spin_direction = 1 if randf() > 0.5 else -1
