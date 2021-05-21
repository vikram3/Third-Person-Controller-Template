extends KinematicBody

var direction = Vector3.BACK
var velocity = Vector3.ZERO
var strafe_dir = Vector3.ZERO
var strafe = Vector3.ZERO

var vertical_velocity = 0
var gravity = 20

var movement_speed = 0
var walk_speed = 1.5
var run_speed = 5

var acceleration = 6
var angular_acceleration = 7

var aim_turn =  0

var roll_magnitude = 17 

func _ready():
	direction = Vector3.BACK.rotated(Vector3.UP, $Camroot/h.global_transform.basis.get_euler().y)

func _input(event):
	
	if event is InputEventMouseMotion:
		aim_turn = -event.relative.x * 0.015
		 
	if !$AnimationTree.get("parameters/roll/active"):
		if event.is_action_pressed("sprint"):
			if $roll_window.is_stopped():
				$roll_window.start()
			
		if event.is_action_released("sprint"):
			if !$roll_window.is_stopped():
				velocity = direction * roll_magnitude
				$roll_window.stop()
				$AnimationTree.set("parameters/roll/active", true)
				$AnimationTree.set("parameters/aim_transition/current", 1)
				$roll_timer.start()

func _physics_process(delta): 
	
	if !$roll_timer.is_stopped():
		acceleration = 3.5
	else:
		acceleration = 5
	
	
	if Input.is_action_pressed("aim"):
		if !$AnimationTree.get("parameters/roll/active"):
			$AnimationTree.set("parameters/aim_transition/current",  0)
	else:
		$AnimationTree.set("parameters/aim_transition/current",  1)
  
	var h_rot = $Camroot/h.global_transform.basis.get_euler().y
	
	if Input.is_action_pressed("forward") || Input.is_action_pressed("backward") || Input.is_action_pressed("left") || Input.is_action_pressed("right"):
	
		direction = Vector3(Input.get_action_strength("left") - Input.get_action_strength("right"),
				0,
				Input.get_action_strength("forward") - Input.get_action_strength("backward"))

		strafe_dir = direction
		
		direction = direction.rotated(Vector3.UP, h_rot).normalized()

		if Input.is_action_pressed("sprint") && $AnimationTree.get("parameters/aim_transition/current") == 1:
			movement_speed = run_speed
#			$AnimationTree.set("parameters/iwr_blend/blend_amount", lerp($AnimationTree.get("parameters/iwr_blend/blend_amount"), 1, delta * acceleration))
		else:
			movement_speed = walk_speed
#			$AnimationTree.set("parameters/iwr_blend/blend_amount", lerp($AnimationTree.get("parameters/iwr_blend/blend_amount"), 0, delta * acceleration))
	else:
		movement_speed = 0
#		$AnimationTree.set("parameters/iwr_blend/blend_amount", lerp($AnimationTree.get("parameters/iwr_blend/blend_amount"), -1, delta * acceleration))
		
		strafe_dir = Vector3.ZERO 
		
		if $AnimationTree.get("parameters/aim_transition/current") == 0:
			direction = $Camroot/h.global_transform.basis.z
	
	velocity = lerp(velocity , direction * movement_speed, delta * acceleration)

	move_and_slide(velocity + Vector3.DOWN * vertical_velocity, Vector3.UP)
	
	if !is_on_floor():
		vertical_velocity += gravity * delta
	else:
		vertical_velocity = 0 
		
	if $AnimationTree.get("parameters/aim_transition/current") == 1:
		$Mesh.rotation.y = lerp_angle($Mesh.rotation.y, atan2(direction.x, direction.z), delta * angular_acceleration)
	else:
		$Mesh.rotation.y = lerp_angle($Mesh.rotation.y, h_rot , delta * angular_acceleration)
		
	strafe = lerp(strafe, strafe_dir + Vector3.RIGHT * aim_turn, delta * acceleration)
	
	$AnimationTree.set("parameters/strafe/blend_position", Vector2(-strafe.x, strafe.z))
	
	var iw_blend = (velocity.length() - walk_speed) / walk_speed
	var wr_blend = (velocity.length() - walk_speed) / (run_speed - walk_speed)

	if velocity.length() <= walk_speed:
		$AnimationTree.set("parameters/iwr_blend/blend_amount", iw_blend)
	else:
		$AnimationTree.set("parameters/iwr_blend/blend_amount", wr_blend)
	
	aim_turn = 0
	
	
