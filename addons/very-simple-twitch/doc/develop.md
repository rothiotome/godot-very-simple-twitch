# Develop

## GDLint
The idea behind installing a linter in this plugin is mainly code readability. That can make collaboration easier for other developers. Using the same consistent coding style makes it easier to collaborate with others and easier to understand what the plugin is doing.

### Installation

There are a few steps before you can use GDLint. You can consult the official documentation, but here's a summary

1. GDLinter is installed on addons folders. You don't need do nothing with it.
2. Deactivate GDLint from pluggins ( project -> configuration -> plugins )
3. Check your python version using 'python --version' or 'py --version'
	- no version installed? 
		- Check windows store for windows  ( best option in my opinion )
		- On Mac 'brew install python' using Homebrew
		- On Linux, you can use APT 'sudo apt install python3'
4. Install godot toolkit using 'pip3 install "gdtoolkit==4.*"'
	- No pip installed? Download the script, from https://bootstrap.pypa.io/get-pip.py and type 'python get-pip.py' to install it.
5. Check gdlint version with 'gdlint --version'
	- Nothing or error showed? try repeating the steps from 2
6. Activate GdLint again.
	- If GDLint menu at the bottom doesnt appear, relaunch godot.


GDScript Toolkit Documentation -> https://github.com/Scony/godot-gdscript-toolkit
GDLinter Addon Documentation -> https://github.com/el-falso/gdlinter/

### Usage

As soon as you install the plugin and the toolkit you will see a menu at the bottom called GDLint. There it will show the problems with the code :)

![](img/gdlint-usage-1.png?raw=true)
