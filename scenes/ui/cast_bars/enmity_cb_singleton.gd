




extends VBoxContainer

class_name EnimityCastBarSingle

@onready var label: Label = %Label
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var timer: Timer = %Timer

var casting: = false


func _process(_delta: float) -> void :
    if casting:
        progress_bar.value = 1 - (timer.time_left / timer.wait_time)


func cast(cast_name: String, cast_time: float) -> void :
    assert ( !casting, "Error: Tried to cast on an active cast bar.")
    label.text = cast_name
    progress_bar.value = 0
    timer.start(cast_time)
    casting = true
    self.show()


func _on_timer_timeout() -> void :
    self.queue_free()
