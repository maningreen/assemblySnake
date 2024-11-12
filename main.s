.data
numFmt: .asciz "%d\n"
.text
.equ yOffset, 8
.equ structSize, 16
.equ bodyChar, 91
.equ headChar, 64
.equ applChar, 83
.equ tickTime, 100000
.equ aKeyCode, 97
.equ dKeyCode, 100
.equ wKeyCode, 119
.equ sKeyCode, 115
.equ QKeyCode, 81
.global main

movePosData:
  //in x0 (better be) the address of the posData
  //in x1 there is y and in x2 is y
  mov x3, x1
  mov x4, x2               //save the offsets
  ldr x1, [x0]              //load the struct from that address
  add x0, x0, yOffset
  ldr x2, [x0]
  sub x0, x0, yOffset
  add x1, x1, x3           //add the values
  add x2, x2, x4           //add the values
  str x1, [x0]    //store the values
  add x0, x0, yOffset//offset the pointer to point to the second element
  str x2, [x0]
  sub x0, x0, yOffset//undo that offset
  mov x0, 0
  ret//return

setPositionData:
  //assume in is in x0
  //and assume that in x1 is x
  //and x2 is y
  str x1, [x0, yOffset]! //put x in struct address and offset it
  str x2, [x0] //store it in the y struct address
  sub x0, x0, yOffset //undo that offset
  ret

addPositionDatas:
  //in x0 is the pointer to a
  //and in x1 is the pointer to b
  str x30, [sp, -16]!//store x30 on the stack to return
  ldr x2, [x1, yOffset]!//set x2 to be the x of b (and offset)
  ldr x3, [x1] //set x3 to be the y of b (and offset)
  mov x1, x2 //move them down to be arguments
  mov x2, x3
  bl movePosData //move the postion data
  ldr x30, [sp], 16 //unload from the stack
  ret //return

drawPositionData:
  // assume position data pointer is in x0
  // assume character pointer is in x1
  // assume screen is in x2
  stp x30, x1, [sp, -16]! //store x30 to return and offset by 16
  //store x1 on the stack too because chances are the rest of them are going to get deleted

  ldr x1, [x0, yOffset]! //load x from x0 struct and offset
  ldr x3, [x0] //load y from the struct pointer
  mov x0, x2 //screen is in x2
  mov x2, x3 //put down the y into arg 2
  bl wmove
  mov x0, sp
  add x0, x0, 8 //so this gave me a bit of trouble so i'll explain it
  //first we mov x0, sp
  //this is so we can manipulate it to our hearts desires
  //(sp in armv8 can only be manipulated by multiples of 16)
  //so we copy it and add 8 onto it this is because we stored
  //two values on the sp x30 and x1
  //x1 had our characters and x30 is 8 byte long so we offset it that many
  //and then we have the address of the character
  //but why not just use the character?
  //well an array is just a pointer, an address is just a pointer,
  //an address, is just an array, and a string is just an array of characters
  //and so we just use the address
  bl printw
  ldp x30, x1, [sp], 16 //load the two we stored and offset sp back
  mov x0, xzr //return 0;
  ret

getKeyPress:
  //this is perhaps the most useless function
  //in the history of functions
  str x30, [sp, -16]! //store to return
  bl getch            //run getch
  ldr x30, [sp], 16   //load to return
  ret //return

getDirFromKeyCode:
  //assume keycode is in x0
  //assume address of reqDir is in x1
  //this isn't hard just really annoying
  //this might ruin our plans for our memory, naw it'll be fine
  str x30, [sp, -16]!
  cmp x0, aKeyCode
  beq 1f
  cmp x0, sKeyCode
  beq 2f
  cmp x0, dKeyCode
  beq 3f
  cmp x0, wKeyCode
  beq 4f //basically just if else array
  mov x0, x1
  mov x1, 2
  mov x2, 0
1:
  //TODO GET RID OF THIS REDUNDANT COPYING INSTRUCTION
  mov x0, x1
  mov x1, 0
  mov x2, -1
  b 1f
2:
  mov x0, x1
  mov x1, 1
  mov x0, 0
  b 1f
3:
  mov x0, x1
  mov x1, 0
  mov x2, 1
  b 1f
4:
  mov x0, x1
  mov x1, -1
  mov x2, 0
1:
  bl setPositionData
  ldr x30, [sp], 16
  ret

delayTick:
  str x30, [sp, -16]!
  mov x0, 4
  mov x0, x0, lsl 6
  add x0, x0, 4
  mov x0, x0, lsl 4
  add x0, x0, 5
  mov x0, x0, lsl 5
  bl usleep
  ldr x30, [sp], 16
  ret

isPos:
  //assume number is in x0
  //check if its greater than or equal to 0
  cmp x0, 0
  bgt  1f //if its less than return 1 for false (cbz)
  mov x0, 1
  b 2f
1:
  mov x0, 0
2:
  ret

wrapPosition:
  //in is in x0
  //maxX andY (struct) are in x2
  //This will be painful

main:
  stp x30, x19, [sp, -16]! //store x30 on the stack so we can return
  stp x20, x21, [sp, -16]!
  stp x22, x23, [sp, -16]!
  stp x24, x25, [sp, -16]!
  stp x26, x27, [sp, -16]!
  str x28, [sp, -16]!

  bl initscr
  mov x22, x0 //set the pointer of the screen to be in x22

  //x22 stdscr
  //x19 maxX, maxY

  mov x0, structSize
  bl malloc
  mov x19, x0 //allocate a struct put the ptr to it in x19
  mov x0, x22
  bl getmaxx
  str x0, [x19, 8]!
  mov x0, x22
  bl getmaxy
  str x0, [x19, -8]!


  //turn of getch delay
  mov x0, x22
  mov x1, 1
  bl nodelay
  //nodelay(stdscr, true);

  mov x0, xzr //arg 1 = 0
  bl curs_set //hide cursor
  //curs_set(0);

  mov x0, structSize //allocate the size of a structure
  bl malloc           //alocate it
  mov x21, x0        //set its address to x21
  mov x1, 12         //set some basic values
  mov x2, 13         //set y
  bl setPositionData //set it for realzies
  mov x0, x21        //put the data in x21
  mov x1, bodyChar   //load the character address
  mov x2, x22        //load the screen
  bl drawPositionData//draw

  bl refresh         //refresh the screen

  bl delayTick

  bl endwin           //uninit screen

  mov x0, x21
  bl free             //free the struct
  mov x0, x19
  bl free             //free maxxy


  ldr x28, [sp],16
  ldp x26, x27, [sp], 16
  ldp x24, x25, [sp], 16
  ldp x22, x23, [sp], 16
  ldp x20, x21, [sp], 16
  ldp x30, x19, [sp], 16 //store x30 on the stack so we can return
  mov x0, xzr   //ret 0
  ret
