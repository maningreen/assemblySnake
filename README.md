# assemblySnake
snake in armv8 assembly

# current status
wip.

expect progress to halt for the time being, my --laptop-- chromebook (it doesn't deserve to be called a laptop) broke
and so i've had to transition devices fairly quickly and am not looking forward to figuring out docker or the alternatives
so i'm just gonna take a brake from assembly and come back to it after a while.

# current progress
you can move, it has snake movement, but if you eat two apples the game crashes. and the core gets dumped. Still working on that growth

and if you run into yourself the game ends.

# requirements to run
you need a few things:
  1. to be able to run armv8 binaries (or armv8 executables the terms mean the same thing)
  2. gcc-aarch64-linux-gnu, and ncurses, using your package manager
  arch based distros: 
  ```
  sudo pacman -S ncurses aarch64-linux-gnu-gcc
  ```
  or with your preferred aur helper

  debian based distros (i'm not sure though, i don't use debian):
```
sudo apt-get install gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu ncurses
```
  3. to be on linux
  4. have ncurses installed
  4. i think that's it. :)

# how to compile
run compile.sh

# how to run
after you run compile.sh

run the snake executable. its in armv8 binaries though, so beware if on x86
