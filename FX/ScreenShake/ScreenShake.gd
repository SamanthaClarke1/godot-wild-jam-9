extends Node

const TRANS = Tween.TRANS_SINE
const EASE = Tween.EASE_IN_OUT

var amp = 0
var priority = 0

onready var camera = get_parent()

func start(dur=0.2, freq=15, amp=5, priority=0):
	if priority >= self.priority:
		self.amp = amp
		self.priority = priority
		
		$Duration.wait_time = dur
		$Frequency.wait_time = 1 / float(freq)
		
		$Duration.start()
		$Frequency.start()
	
	_new_shake()

func _new_shake():
	var rand = Vector2(rand_range(-amp, amp), rand_range(-amp, amp))
	
	$ShakeTween.interpolate_property(camera, "offset", camera.offset, rand, $Frequency.wait_time, TRANS, EASE)
	$ShakeTween.start()

func _reset():
	$ShakeTween.interpolate_property(camera, "offset", camera.offset, Vector2(), $Frequency.wait_time, TRANS, EASE)
	$ShakeTween.start()
	print('RESET SHAKE')
	
	priority = 0
	$Frequency.stop()
	$Duration.stop()

func _on_Frequency_timeout():
	_new_shake()

func _on_Duration_timeout():
	_reset()
