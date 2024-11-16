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
  2. gcc-aarch64-linux-gnu, using your package manager
  arch based distros: 
  ```
  yay -S gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu
  ```
  or with your prefered aur helper
  debian based distros:
```
sudo apt-get install gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu
```
  3. i think thats it. :)

# how to compile
run compile.sh
