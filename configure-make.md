# How to run Make from CMD
`make` is command line tool related to Linux environment so you can't use it in windows CMD or PowerShell. To use `make` in windows envronment you have to install either MINGW 
or cygwin. This file illestrates how to install cygwin step by step then integrate cygwin into vscode

## Cygwin Installation
1. Download cygwin installer from this [link](https://cygwin.com/install.html).
2. Run cygwin installer.
3. In choose package type make in search bar and the new column choose a version to be installed (any version) - I selected all automake packages and cmake - then press next
4. After cygwin installation a cygwin shotcut will be on the desktop
5. open cygwin terminal (from the desktop shotcut) and type make (You should see `make: *** No targets specified and no makefile found.  Stop.`) if another output is shown please contact me (Most probably make was't installed in cygwin, error happend with step 3)

## Integrate Cygwin with VSCode
1. From VSCode extensions install `shell launcher`
2. press the gear button (Manage) and select keyboard shotcut
3. open KeyBindings.json and add these lines
``` json
// Place your key bindings in this file to override the defaults
[{
  "key": "ctrl+shift+t",
  "command": "shellLauncher.launch"
}]
```
4. press the gear button (Manage) and select settings
5. search for launcher and from `Shell launcher Shells:windows` press `Edit in Settings Json`
6. Add this json object in the `shellLauncher.shells.windows` list 
``` json
{
  "shell": "C:\\cygwin64\\bin\\bash.exe",
  "args": ["--login"],
  "label": "Cygwin Bash",
  "env": {"CHERE_INVOKING": "1"},
  "launchName": "Cygwin Bash",
},
```
7. Press `ctrl+shift+t` and choose Cygwin Bash 