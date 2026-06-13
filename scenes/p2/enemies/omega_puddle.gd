extends Node3D

func play_expand() -> void :
		var tween = create_tween()
		tween.tween_property(self, "scale", 9*Vector3(1,1,1), 1.5)\
			.set_trans(Tween.TRANS_QUINT)\
			.set_ease(Tween.EASE_OUT)
		await tween.finished

func play_shrink() -> void :
		var tween = create_tween()
		tween.tween_property(self, "scale", 1*Vector3(1,1,1), 1.5)\
			.set_trans(Tween.TRANS_QUINT)\
			.set_ease(Tween.EASE_OUT)
		await tween.finished
		self.visible = false
		self.queue_free()
