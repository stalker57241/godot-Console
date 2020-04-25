extends Panel

enum Error {
	ERR_DIRECTORY_ALREADY_EXISTS = 49
}
onready var text_edit = $TextEdit
var locked_chars = [
	KEY_UP,
	KEY_DOWN,
	KEY_LEFT,
	KEY_RIGHT,
	KEY_TAB,
	KEY_SHIFT,
	KEY_CONTROL,
	KEY_ESCAPE,
	KEY_ALT,
	KEY_F1,
	KEY_F2,
	KEY_F3,
	KEY_F4,
	KEY_F5,
	KEY_F6,
	KEY_F7,
	KEY_F8,
	KEY_F9,
	KEY_F10,
	KEY_F11,
	KEY_F12,
	KEY_DELETE]
var numbers = [
	KEY_0,
	KEY_1,
	KEY_2,
	KEY_3,
	KEY_4,
	KEY_5,
	KEY_6,
	KEY_7,
	KEY_8,
	KEY_9]

var bindings = {
	"res://root/": "/",
	"res://root/home": "~"
}

var user = "Stalker57241"
var completing_command: bool = false
var pwd = Directory.new()
var curr_dir = pwd.get_current_dir()

func _ready():
	pwd.change_dir("res://root/")
	shell()

func dir_contents(path):
	if pwd.open(path) == OK:
		pwd.list_dir_begin()
		var file_name = pwd.get_next()
		while file_name != "":
			if pwd.current_is_dir():
				write("FOLDER" + "\t" + file_name)
			else:
				
				write("FILE" + "\t".repeat(2) + file_name)
			file_name = pwd.get_next()
	else:
		write("An error occurred when trying to access the path.")

func mkdir(path) -> int:
	if self.pwd.make_dir(path) == OK:
		return OK
	else:
		write("An error occured when trying to create the directory")
		return self.Error.ERR_DIRECTORY_ALREADY_EXISTS

func write(string: String, ending: String="\n"):
	self.text_edit.text += string + ending

func parser(txt: PoolStringArray):
	if txt[0] == 'exit':
		get_tree().quit(0)
	if txt[0] == 'clear':
		self.text_edit.text = ""
	if txt[0] == 'pwd':
		self.text_edit.text += self.curr_dir + "\n"
	if txt[0] == "ls" or txt[0] == "dir":
		if txt.size() > 1:
			self.dir_contents(txt[1])
		else:
			self.dir_contents(self.pwd.get_current_dir())
	if txt[0] == "echo":
		var res = ""
		for t in txt:
			if t == txt[0]: continue
			res += t + " "
		write(res, "\n")
	if txt[0] == "cd":
		if txt[1] != null:
			pwd.change_dir(txt[1])
			write("")
	if txt[0] == "mkdir":
		mkdir(txt[1])
	if txt[0] == "rm":
		if pwd.remove(txt[1]) == OK:
			write("directory " + txt[1] + " have been removed", "\n")
		else:
			write("directory not found or it is not empty")

func shell():
	var prompt = "[" + self.user + "] " + self.pwd.get_current_dir() + ": "
	chars_in_cmd = 0
	var txt = text_edit.text.strip_escapes().split(prompt)
	self.parser(txt[txt.size() - 1].split(" "))
	self.write(prompt, "")
	self.completing_command = false

var caps_lock: bool = false
var chars_in_cmd: int = 0
var timer = 0

func _process(delta):
	timer += delta
	if $AudioStreamPlayer.playing and timer >= 0.58:
		$AudioStreamPlayer.stop()
		timer = 0

func _input(event):
	if event is InputEventKey and event.pressed and not self.completing_command:
		if not $AudioStreamPlayer.playing:
			$AudioStreamPlayer.play()
		if event.scancode == KEY_BACKSPACE:
			if self.chars_in_cmd >= 1:
				self.text_edit.text[text_edit.text.length() - 1] = ""
				self.chars_in_cmd -= 1
			else: return
		elif event.scancode == KEY_ENTER:
			text_edit.text += "\n"
			shell()
		elif event.scancode == KEY_CAPSLOCK: self.caps_lock = !self.caps_lock
		elif event.scancode in self.locked_chars: return
		else:
			chars_in_cmd += 1
			if event.scancode == KEY_COMMA: text_edit.text += ","
			elif event.scancode == KEY_PERIOD: text_edit.text += "."
			elif event.scancode == KEY_SLASH: text_edit.text += "/"
			elif event.scancode == KEY_SPACE: text_edit.text += " "
			elif event.scancode == KEY_APOSTROPHE: text_edit.text += "'"
			elif event.scancode == KEY_SEMICOLON: 
				if not caps_lock: text_edit.text += ";"
				else: text_edit.text += ":"
			elif event.scancode == KEY_BACKSLASH: text_edit.text += "\\"
			elif event.scancode == KEY_MINUS: text_edit.text += "-"
			elif event.scancode == KEY_EQUAL: text_edit.text += "="
			elif event.scancode in self.numbers or self.caps_lock: self.text_edit.text += OS.get_scancode_string(event.scancode)
			else: self.text_edit.text += OS.get_scancode_string(event.scancode + 32)
