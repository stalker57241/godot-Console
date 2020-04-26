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

onready var pwd = Directory.new()
onready var variables = {
	"prompt": ("[%user%] " + pwd.get_current_dir() + " > "),
	"user": "Stalker57241"
}


func _ready():
	self.variables = {
		"prompt": ("[Stalker57241] "),
		"user": "Stalker57241"
	}
	self.write("", "")
	self.text_edit.text = ""
	pwd.change_dir("res://root/")
	shell()

func ls(path):
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

func get_dir_content(path):
	var res = []
	if pwd.open(path) == OK:
		pwd.list_dir_begin()
		var file_name = pwd.get_next()
		while not file_name.empty():
			if not pwd.current_is_dir():
				res.append(file_name)
			else: continue
			file_name = pwd.get_next()
		print(res)
		return res
	else:
		write("An error occurred when trying to access the path.")

func mkdir(path):
	if self.pwd.make_dir(path) == OK:
		return
	else:
		write("An error occured when trying to create the directory")

func write(string: String, ending: String="\n"):
	self.text_edit.text += string + ending

func parser(txt: PoolStringArray):
	if txt[0].length() == 0:
		return
	elif txt[0] == "exit":
		get_tree().quit(0)
	elif txt[0] == "clear":
		self.text_edit.text = ""
	elif txt[0] == "pwd":
		self.text_edit.text += self.pwd.get_current_dir() + "\n"
	elif txt[0] in ["ls", "dir"]:
		if txt.size() > 1:
			self.ls(txt[txt.size() - 1])
		else:
			self.ls(self.pwd.get_current_dir())
	elif txt[0] == "echo":
		var res = ""
		for t in txt:
			if t == txt[0]: continue
			res += t + " "
		write(res, "\n")
	elif txt[0] == "cd":
		if txt.size() > 1:
			pwd.change_dir(txt[txt.size() - 1])
		else:
			parser(PoolStringArray(["pwd"]))
	elif txt[0] == "mkdir":
		mkdir(txt[1])
	elif txt[0] == "rm":
		if pwd.remove(txt[1]) == OK:
			write("directory " + txt[1] + " have been removed", "\n")
		else:
			write("directory not found or it is not empty")
	elif txt[0] == "set":
		if txt.size() > 1:
			var tmp = txt[1].split("=")
			self.variables[tmp[0]] = tmp[1]
		else:
			for vars in self.variables:
				write(vars + "=" + self.variables[vars])
	elif txt[0] == "exec":
		var cont = self.get_dir_content(self.pwd.get_current_dir())
		if txt[1] in cont:
			if txt[1].ends_with(".gd"):
				var script = load(txt[0])
				if script.has_method("_start"):
					script._start(self)
				else:
					write("Script hasn't _start(object) method")
			else:
				var exec = []
				for e in txt:
					if txt[0] == e: continue
					exec.append(e)
				var res = []
# warning-ignore:return_value_discarded
				OS.execute(self.pwd.get_current_dir() + "/" + txt[0], exec, true, res)
				write(res)

func shell():
	chars_in_cmd = 0
	var txt = text_edit.text.strip_escapes().split(variables["prompt"] + pwd.get_current_dir() + " > ")
	self.parser(txt[txt.size() - 1].split(" "))
	self.write(variables["prompt"] + pwd.get_current_dir() + " > ", "")

var caps_lock: bool = false
var chars_in_cmd: int = 0
var timer = 0

func _process(delta):
	timer += delta
	if $AudioStreamPlayer.playing and timer >= 0.58:
		$AudioStreamPlayer.stop()
		timer = 0

func _input(event):
	if event is InputEventKey:
		if event.scancode == KEY_SHIFT:
			self.caps_lock = event.pressed
	if event is InputEventKey and event.pressed:
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
			elif self.caps_lock:
				if   event.scancode == KEY_1: text_edit.text += "!"
				elif event.scancode == KEY_2: text_edit.text += "@"
				elif event.scancode == KEY_3: text_edit.text += "#"
				elif event.scancode == KEY_4: text_edit.text += "$"
				elif event.scancode == KEY_5: text_edit.text += "%"
				elif event.scancode == KEY_6: text_edit.text += "^"
				elif event.scancode == KEY_7: text_edit.text += "&"
				elif event.scancode == KEY_8: text_edit.text += "*"
				elif event.scancode == KEY_9: text_edit.text += "("
				elif event.scancode == KEY_0: text_edit.text += ")"
				elif event.scancode == KEY_MINUS: text_edit.text += "_"
				elif event.scancode == KEY_EQUAL: text_edit.text += "+"
				else: self.text_edit.text += OS.get_scancode_string(event.scancode)
			else: self.text_edit.text += OS.get_scancode_string(event.scancode + 32)
