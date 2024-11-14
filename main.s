.data
numFmt: .asciz "%d, %d\n"
.text
.equ yOffset, 8
.equ structSize, 16
.equ bodyChar, 91
.equ headChar, 64
.equ applChar, 83
.equ aKeyCode, 97
.equ dKeyCode, 100
.equ wKeyCode, 119
.equ sKeyCode, 115
.equ QKeyCode, 81
.global main

getPosDataVals:
  //x0 is pointer
  mov x3, x0
  ldr x0, [x3, yOffset]!
  ldr x1, [x3, -yOffset]!
  ret

initPosData:
  //assume x0 is value x
  //assume x1 is value y
  //*MAKE SURE TO RETURN POINTER TO IT*
  stp x30, x21, [sp, -16]!
  stp x0, x1, [sp, -16]!
  mov x0, structSize
  bl malloc
  mov x21, x0
  ldp x1, x2, [sp], 16
  bl setPositionData
  mov x0, x21
  ldp x30, x21, [sp], 16
  ret

movePosData:
  //in x0 (better be) the address of the posData
  //in x1 there is y and in x2 is y
  mov x3, x1
  mov x4, x2               //save the offsets
  ldr x1, [x0], yOffset    //load the struct from that address
  ldr x2, [x0], -yOffset
  add x1, x1, x3           //add the values
  add x2, x2, x4           //add the values
  str x1, [x0, yOffset]!    //store the values
  str x2, [x0, -yOffset]!
  ret//return

setPositionData:
  //assume in is in x0
  //and assume that in x1 is x
  //and x2 is y
  str x1, [x0, yOffset]!
  str x2, [x0, -yOffset]!
  ret

addPositionDatas:
  //in x0 is the pointer to a
  //and in x1 is the pointer to b
  str x30, [sp, -16]!//store x30 on the stack to return
  ldr x2, [x1], -yOffset//set x2 to be the x of b (and offset)
  ldr x3, [x1] //set x3 to be the y of b (and offset)
  mov x1, x2 //move them down to be arguments
  mov x2, x3
  bl movePosData //move the postion data
  ldr x30, [sp], 16 //unload from the stack
  ret //return

printPositionData:
  //posDataPtr is in x0
  str x30, [sp, -16]! //store this to return
  bl getPosDataVals //get the data values
  //move them up to match the number format
  mov x2, x1        //move y into x2
  mov x1, x0        //move x into x1
  adrp x0, numFmt   //load numFmt from memory
  add x0, x0, :lo12:numFmt
  bl printf         //print values
  ldr x30, [sp], 16
  ret

drawPositionData:
  // assume position data pointer is in x0
  // assume character pointer is in x1
  // assume screen is in x2
  stp x30, x1, [sp, -16]! //store x30 to return and offset by 16
  //store x1 on the stack too because chances are the rest of them are going to get deleted
  //don't worry about x1 anymore
  //move the cursor
  bl getPosDataVals
  mov x0, x2
  mov x1, x3
  mov x2, x4
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
  ldr x30, [sp], 16 //load the two we stored and offset sp back
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
  mov x0, x1
  beq 4f //basically just if else array
  mov x1, 2
  mov x2, 0
  b 5f
1:
  mov x1, 0
  mov x2, -1
  b 5f
2:
  mov x1, 1
  mov x0, 0
  b 5f
3:
  mov x1, 0
  mov x2, 1
  b 5f
4:
  mov x1, -1
  mov x2, 0
5:
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
  stp x20, x21, [sp, -16]! //store the rest on the stack so we can return
  stp x22, x23, [sp, -16]!
  stp x24, x25, [sp, -16]!
  stp x26, x27, [sp, -16]!
  str x28, [sp, -16]!

  bl initscr  //get stdscr
  mov x22, x0 //put that baby in x22

  bl getmaxy //get the maximum y value
  mov x1, x0 //set it in x1
  mov x0, x22//put stdscr as arg 1
  bl getmaxx //get maxx (its in x0)
  bl initPosData //make a pos data from this

  mov x19, x0       //recall the max vals are in x19
  bl getPosDataVals //get the max pos values
  sub x0, x0, 1     //subtract both values by one because its not inclusive (should probably do that up there)
  sub x1, x1, 1     //again that ^
  mul x0, x0, x1    //get the maximum length from the area of the screen

  //get the won condition (false)
  mov x1, 0 //zero for false (cbz my best friend)

  bl initPosData
  mov x20, x0   //pointer output is in x0 put it in x20 for future reference.
  bl printPositionData //for debugging


  //x19 maxVals
  //x20 maxLength, won
  //x21, box
  //x22 stdscr
  //x23, apple
  //x24, bodyLength
  //x25, bodyArray
  //x26, direction
end:
  mov x0, x22
  bl endwin //end the window

  mov x0, x19 //free maxVals
  bl free

  mov x0, x20 //free maxLength and won
  bl free

  ldr x28, [sp], 16
  ldp x26, x27, [sp], 16
  ldp x24, x25, [sp], 16
  ldp x22, x23, [sp], 16
  ldp x20, x21, [sp], 16
  ldp x30, x19, [sp], 16
  mov x0, xzr   //ret 0
  ret
