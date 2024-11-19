# assemblySnake
snake in armv8 assembly

# current status
wip, not complete --(expect a week or two to be finished)--
expect around 3 weeks.

# current progress
you can move, it has snake movement, but if you eat two apples the game crashes. and the core gets dumped. Still working on that growth

(IT DOESNT DUMP ON THE RELEASED VERSION, only on the development one :), only i deserve to suffer)

working on that.

and if you run into yourself the game ends.

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
