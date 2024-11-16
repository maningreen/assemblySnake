# assemblySnake
snake in armv8 assembly

# current status
wip, not complete (expect a week or two to be finished)

# current progress
right now, it responds to player input, and there is a 'player'
implementing a body for the snake next. Expect that to take a while.

# requirements to run
you need a few things:
  1. to be able to run armv8 binaries (or armv8 executables the terms mean the same thing)
  2. gcc-aarch64-linux-gnu, and ncurses, using your package manager
  arch based distros: 
  ```
  yay -S gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu
  sudo pacman -S ncurses
  ```
  or with your preferred aur helper

  debian based distros (idk tho i use arch btw):
```
sudo apt-get install gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu ncurses
```
  3. to be on linux
  4. have ncurses installed
  4. i think that's it. :)

# how to compile
run compile.sh
