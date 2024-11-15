.data
numFmt: .asciz "%d, %d\n"
.text
.equ yOffset, 8
.equ negYOffset, -8
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

modulo:
  //assume x0 is a
  //and x1 is b
  udiv x3, x0, x1 // x3 = a/b 
  mul x3, x3, x1  // x3 = b * x3
  sub x0, x0, x3  // x0 = a - x3
  ret             //return that value

getPosDataVals:
  //x0 is pointer
  add x0, x0, yOffset
  ldr x1, [x0], negYOffset
  ldr x0, [x0]
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
  ldr x3, [x0], yOffset
  ldr x4, [x0], negYOffset
  add x1, x1, x3
  add x2, x2, x4
  str x1, [x0]
  str x2, [x0, yOffset]
  ret

setPositionData:
  //assume in is in x0
  //and assume that in x1 is x
  //and x2 is y
  str x1, [x0, yOffset]!
  str x2, [x0, negYOffset]!
  ret

setPositionDataToOtherData:
  //assume in x0 is the pointer to set
  //assume in x1 is the pointer to read
  str x30, [sp, -16]! //load x30 to the stack
  mov x3, x0
  mov x0, x1
  bl getPosDataVals
  mov x2, x1
  mov x1, x0
  mov x0, x3
  bl setPositionData     //then we set the pos data
  ldr x30, [sp], 16      //load x30 from the stack
  ret                    //and return
  

addPositionDatas:
  //in x0 is the pointer to a
  //and in x1 is the pointer to b
  str x30, [sp, -16]! //store x30 to return
  str x0, [sp, -16]!  //store x0 to write to
  mov x3, x1          //put this here for safekeeping
  add x0, x0, yOffset //offset it to load in the y first
  ldr x1, [x0], negYOffset//loads the y from x0 and unofsets
  ldr x0, [x0]        //loads the x from x0
  ldr x2, [x3], yOffset//load the x from arg 2
  ldr x3, [x3]        //loads the y from arg 2
  add x3, x1, x3      //add the y from arg 1 and from arg 2 and puts it in x3
  add x1, x0, x2      //add the x from arg 1 and from arg 2 and puts it in x1
  mov x2, x3          //put the y sum into x2 to call set pos data
  ldr x0, [sp], 16    //load arg 1 from the stack and put it in x0
  bl setPositionData
  ldr x30, [sp], 16   //load x30 to return
  ret //return

getPosDataDif:
  //x0 is pointer 1
  //x1 is pointer 2
  ldp x2, x3, [x0] //load both the values from x0
  ldp x4, x5, [x1] //load both values from x1
  sub x0, x2, x4   //get the difference of x values put in x0
  sub x1, x3, x5   //get the difference of y values put in x1
  ret              //return

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
  str x2, [sp, -16]!
  //store x1 on the stack too because chances are the rest of them are going to get deleted
  //don't worry about x1 anymore or x2
  //move the cursor
  bl getPosDataVals //x1 is stored on stack, overrides the pointer
  mov x2, x1        //set x2 to be the y
  mov x1, x0        //set x1 to be the x
  ldr x0, [sp], 16  //load screen from stack
  bl wmove          //move the cursor

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
  str x30, [sp, -16]! //store x30 and offset it
  //assume in x0 is the pointer
  //assume in x1 is the keycode
  //time for a fat if else array
  cmp x1, aKeyCode
  beq 1f
  cmp x1, dKeyCode
  beq 2f
  cmp x1, wKeyCode
  beq 3f
  cmp x1, sKeyCode
  beq 4f
  //THIS IS NOW IF ITS NONE OF THEM
  mov x1, 2 //x = 2
  mov x2, 0 //y = 0
  b 5f
1:
  mov x1, 0
  mov x2, -1
  b 5f
2:
  mov x1, 0
  mov x2, 1
  b 5f
3:
  mov x1, -1
  mov x2, 0
  b 5f
4:
  mov x1, 1
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
  //very painful

main:
  stp x30, x19, [sp, -16]! //store x30 on the stack so we can return
  stp x20, x21, [sp, -16]! //store the rest on the stack so we can return
  stp x22, x23, [sp, -16]!
  stp x24, x25, [sp, -16]!
  stp x26, x27, [sp, -16]!
  str x28, [sp, -16]!

  bl initscr  //get stdscr
  mov x22, x0 //put that baby in x22

  //recall stdscr is in x0 ^
  mov x1, 1   //set arg 2 to true
  bl nodelay

  mov x0, 0
  bl curs_set //make the cursor invisible

  mov x0, x22//set arg 1 to be stdscr
  bl getmaxx //get the maximum y value
  sub x1, x0, 1 //sub 1 to make it inclusive, put it in x1
  mov x0, x22//put stdscr as arg 1
  bl getmaxy //get maxx (its in x0)
  sub x0, x0, 1 //sub 1 to make it inclusive put it in x0
  bl initPosData //make a pos data from this
  mov x19, x0    //store max vals in x19

  //x20 is maxLength and won condition
  bl getPosDataVals
  mul x0, x0, x1
  mov x1, 0
  bl initPosData
  mov x20, x0

  //next its time to instantiate our box, this should have two things
  //an x value and a y value, both at the center of the screen
  mov x0, x19 //max vals are in here (inclusive (what we want))
  bl getPosDataVals
  mov x3, 2      //for some reason  udiv requires registers
  udiv x0, x0, x3 //divide by two to get center of screen
  udiv x1, x1, x3 //divide by two to get center of the screen
  bl initPosData
  mov x21, x0

  mov x0, 0     //set collumn to 0 for initial direction
  mov x1, -1    //set row to -1 for initiate direction <--
  bl initPosData
  mov x26, x0
  //set x26 to be our position data

  //reqDir
  mov x0, 0     //set it to 1 temporarily
  mov x1, x0    //seti it to 1 (this will get immediatly overwriten)
  bl initPosData//initiate it
  mov x27, x0   //set x27 to reqDir

  //x19 maxVals
  //x20 maxLength, won
  //x21, box
  //x22 stdscr
  //x23, apple
  //x24, bodyLength
  //x25, bodyArray
  //x26, direction
  //x27, reqDir
gameLoop:

  bl clear
  bl getKeyPress
  cmp x0, QKeyCode //check if they're the same
  beq end          //if so go to end

  //change position
  mov x0, x21 //load args
  mov x1, 1
  mov x2, 0
  bl movePosData

  mov x0, x21
  mov x1, headChar//set the character the head character
  mov x2, x22    //set the screen to draw on to be std screen
  bl drawPositionData//draw the position

  bl refresh

  bl delayTick    //delay the game by .1 seconds

  b gameLoop

end:
  mov x0, x22
  bl endwin //end the window

  mov x0, x19 //free maxVals
  bl free

  mov x0, x20
  bl free

  mov x0, x21 //free the head pos
  bl free

  mov x0, x26 //free direction
  bl free

  mov x0, x27 //free reqDir
  bl free

  ldr x28, [sp], 16
  ldp x26, x27, [sp], 16
  ldp x24, x25, [sp], 16
  ldp x22, x23, [sp], 16
  ldp x20, x21, [sp], 16
  ldp x30, x19, [sp], 16
  mov x0, xzr   //ret 0
  ret
