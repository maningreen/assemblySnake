.data
numFmt: .asciz "%d, %d"
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

modulo:
  //assume x0 is a
  //and x1 is b
  udiv x3, x0, x1 // x3 = a/b 
  mul x3, x3, x1  // x3 = b * x3
  sub x0, x0, x3  // x0 = a - x3
  ret             //return that value

abs:
  cmp x0, 0
  blt 1f
  b 2f
1:
  mov x1, -1
  mul x0, x0, x1
2:
  ret

getPosDataVals:
  //x0 is pointer
  add x0, x0, yOffset
  ldr x1, [x0]
  sub x0, x0, yOffset
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
  ldr x3, [x0]
  ldr x4, [x0, yOffset]
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

setPosDataToOtherData:
  //assume in x0 is the pointer to set
  //assume in x1 is the pointer to read
  ldr x2, [x1]          //get the data
  ldr x3, [x1, yOffset]
  str x3, [x0]          //store the data
  str x2, [x0, yOffset] //NOTE: the setting is reversed, this is because when i was writing this initally i  was very lazy
  //and did it poorly, the correct version is below
  ret                    //and return

setPosDataToOtherDataFixed:
  //x0 has the ptr to set
  //x1 has the ptr to read
  ldr x2, [x1]
  ldr x3, [x1, yOffset]
  str x2, [x0]
  str x3, [x0, yOffset]
  ret

movePosDataByOtherPosData:
  str x30, [sp, -16]! //store x30 on the stack and increment by -16
  //assume at x0 is the pos data to move
  //assume at x1 is the pos data to move by
  ldr x2, [x1]
  ldr x1, [x1, yOffset]
  bl movePosData
  ldr x30, [sp], 16   //load x30 to return
  ret //return

getPosDataSum:
  //x0 is pointer 1
  //x1 is pointer 2
  ldr x2, [x0]
  ldr x4, [x1]
  add x0, x0, yOffset
  add x1, x1, yOffset
  ldr x3, [x0]
  ldr x5, [x1]
  add x0, x2, x4   //get the difference of x values put in x0
  add x1, x3, x5   //get the difference of y values put in x1
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
  //and by equality an address is just a string
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
  mov x1, 0 //x = 2
  mov x2, 2 //y = 0
  b 5f
1:
  mov x1, -1
  mov x2, 0
  b 5f
2:
  mov x1, 1
  mov x2, 0
  b 5f
3:
  mov x1, 0
  mov x2, -1
  b 5f
4:
  mov x1, 0
  mov x2, 1
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
  bge 1f
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
  //in fact so painful we are going to be storing some registers
  str x30, [sp, -16]! //store this so we can return
  stp x19, x20, [sp, -16]! //the rest of thses are just to store data
  stp x21, x22, [sp, -16]!
  stp x23, x24, [sp, -16]!

  mov x23, x0 //loading these in so we don't have to worry about overriding thme later
  mov x24, x1

  // 1: getting less than maxX
  ldr x0, [x0] //recall in x0 is the struct
  ldr x1, [x1, yOffset] //and in x1 is the maxPoses
  //we have to offset because that ones in reverse
  cmp x0, x1  //if its less than / equal to we set to true
  bge 1f
  //here we are if its true
  mov x19, 0
  // the reason we set it to 0 for true will be apparent soon
  b 2f
1:
  mov x19, 1
2:
  // 1.5: getting less than maxY
  ldr x0, [x23, yOffset] //x23 has struct
  ldr x1, [x24]  //x24 has maxVals, (they in reverse tho)
  cmp x0, x1 //compare if its less than / equel we set to true
  bge 1f
  //we are true here now
  mov x20, 0
  b 2f
1:
  mov x20, 1
2:
  // 2: getting if pos or not
  ldr x0, [x23] //load x value from memory
  bl isPos      //this returns it in the format we want
  mov x21, x0   //store the output in x21
  ldr x0, [x23, yOffset] //load the y value from ememory
  bl isPos      //in the correct format
  mov x22, x0   //put the output in x22

  //add them together for an "and"
  add x0, x19, x21 //group all the x related ones together
  add x1, x20, x22 //group all the y related ones together
  add x1, x0, x1   //add them together (this is why our format was true 0, false 1)
  cbz x1, 99f       //if they're all 0 (true) then we can leave

  cbz x0, 44f     //if the x related ones are 0 (true) then somethings u with the y axis

  ldr x0, [x23]
  ldr x1, [x24, yOffset]

  cbz x19, 11f     //if it is less then maxX then we know its negative
  //we now know that it is too big, so we modulo it
  bl modulo
  b 22f
11:
  //here we know that its negative
  //maxX - abs(x)
  //we know its negative so then it beomes
  //maxX + x
  add x0, x0, x1
22:
  //here we store the value
  str x0, [x23]
  b 99f //and then return
44:
  //this is practically the same as the x but with some registers different and some offsets different, don't expect good cmetns here

  ldr x0, [x23, yOffset]
  ldr x1, [x24]
  cbz x20, 45f
  bl modulo
  b 46f
45:
  add x0, x0, x1
46:
  str x0, [x23, yOffset]
  //x19: is less than maxX (BOOL)
  //x20: is less than maxY (BOOl)
  //x21: is negative, x    (BOOl)
  //x22: is negative, y    (BOOl)
  //x23: struct to wrap    (POINTER)
  //x24: maxX and maxY struct (POINTER)

99:
  ldp x23, x24, [sp], 16 //load all the stuff from the stack to return
  ldp x21, x22, [sp], 16
  ldp x19, x20, [sp], 16
  ldr x30, [sp], 16      //in reverse order too
  ret

initBody:
  //x0 has the requested size, we supply the ptr
  //x1, should have maxx, maxy ptr
  str x30, [sp, -16]!

  str x1, [sp, -16]!    //store maxxy on the stack

  mov x1, structSize
  mul x0, x0, x1
  mov x1, x0
  str x1, [sp, -16]!      //store size on the stack
  bl malloc

  ldr x1, [sp], 16        //now x1 has the size* (not quite what we want)
  sub x1, x1, structSize  //now it has what we want

  //x0 has the ptr x1 has the size
  mov x2, x0
  ldr x3, [sp], 16        //load the stdscr from the stack
  str x2, [sp, -16]!      //store this so we can write to it w/o worry

  add x0, x0, x1          //what we're going to do here is w a c k
  mov x3, 0
1:
  cmp x1, 0
  blt 1f

  str x3, [x0]
  str x3, [x0, yOffset]

  sub x0, x0, x2    //(its wack)
  sub x1, x1, x2
  b 1b
1:
  ldr x0, [sp], 16        //load ptr from the stack
  ldr x30, [sp], 16
  ret

printBody:
  //assume two things
  //x0 has ptr
  //x1 has size
  //x2 has the screen
  str x30, [sp, -16]! //do this to return
  stp x19, x20, [sp, -16]! //do this to store the ptr and size
  str x21, [sp, -16]!

  mov x19, x0   //put the pointer into x19
  mov x20, x1   //put the size into x20
  mov x21, x2   //put tthe screen pt in x21
1:
  cmp x20, 0  //if x20 is less than 0
  blt 99f     //then we end
  //pointer math jumpscare
  //so first we have to load the stuff from memory
  //well we have a function that does all the hard things
  mov x0, x19 //pointers in x19
  mov x1, structSize //put the size into x1
  mul x1, x1, x20    //multiply the size with the structSize
  add x0, x0, x1
  mov x1, bodyChar   //put the bodychar to be the character
  mov x2, x21        //put the screen in x2
  bl drawPositionData//draw them
  sub x20, x20, 1   //de-increment the counter
  b 1b              //go back to 1b
99:
  ldr x21, [sp], 16
  ldp x19, x20, [sp], 16  //pop off the stack
  ldr x30, [sp], 16   //again to return
  ret

moveBody:
  //x0 should have the head struct
  //x1 should have the ptr to the array
  //x2 should have the array size
  mov x3, structSize
  sub x2, x2, 1
  mul x2, x2, x3
1:
  cmp x2, 0
  blt 1f
  add x3, x1, x2
  sub x2, x2, structSize
  add x4, x1, x2
  ldr x5, [x4]
  ldr x6, [x4, yOffset]
  str x5, [x3]
  str x6, [x3, yOffset]
  b 1b
1:
  ldr x3, [x0]
  ldr x4, [x0, yOffset]
  str x3, [x1]
  str x4, [x1, yOffset]
  ret

setPosRand:
  //x0 has ptr to set
  //x1 has maxX, maxY
  //sets a potition data to a random position. ye.
  str x30, [sp, -16]!
  stp x20, x21, [sp, -16]!

  mov x20, x1
  mov x21, x0

  //srand(time(NULL));
  mov x0, xzr
  bl time
  bl srand

  bl rand
  str x0, [x21]
  bl rand
  str x0, [x21, yOffset]

  mov x0, x21
  mov x1, x20
  bl wrapPosition
  mov x0, x21
  mov x1, x20
  bl wrapPosition //run wrap twice, it only accounts for x, and y one at a time

  ldp x20, x21, [sp], 16
  ldr x30, [sp], 16
  ret

getColliding:
  //x0 has ptr 1
  //x1 has ptr 2
  ldr x3, [x1, yOffset]
  ldr x2, [x1]
  ldr x1, [x0, yOffset]
  ldr x0, [x0]
  cmp x0, x2
  bne 1f
  cmp x1, x3
  bne 1f
  mov x0, 1
  b 2f
1:
  mov x0, 0
2:
  ret

getCollidingWithBody:
  //x0 has what we want to chec
  //x1 has the bodyarray
  //x2 has the bodyLength

  //in c it'd go someting like this
  //funcName(posData item, posData* bodyArray, int bodyLength) {
  //  bodyLength--;
  //  while(bodyLength >= 0) {
  //    if(getColliding(head, *(bodyarray + bodyLength)))
  //      return true;
  //    bodyLength--;
  //  }
  //  return false
  //}
  //ore something lke that
  //of course its GOING to be different because we wouldn't dereference and its all pointers
  //ITS ALL POINTERS!?
  //always has been.
  str x30, [sp, -16]! //store x30 on the stack so we can return :D
  stp x20, x21, [sp, -16]! //store x20, and x21 on the stack so we can write stuff
  str x22, [sp, -16]!  //store x22 on the stack to write stuff in that register

  //x0 has item to check
  //x1 has array
  //x2 has length of array
  mov x20, x0   //store it so we can do stuff
  mov x21, x1   //store it so we can reference it later
  sub x22, x2, 1//bodyLength--; //:) (its quicker), also here we want to put it in bytes
  mov x0, structSize
  mul x22, x22, x0 //here we're turning it into bytes so we do less thinking in the end

  //TODO
  //only load the x and y of the single item once
  //touch memory less

1:
  //LOOP
  cmp x22, 0    //while -->(bodyLength >= 0)<--
  blt 98f

  ldr x0, [x20] //load primary thing
  add x2, x21, x22
  ldr x1, [x2] //array x item it at an offset
  cmp x0, x1
  bne 3f        //if this isn't the same we just skip lol
  //now we know at least the x's are the same
  ldr x0, [x20, yOffset] //load the primary y val
  ldr x1, [x2, yOffset]  //load the secondary y val
  cmp x0, x1
  bne 3f
  //ITS TRUE :O
  mov x0, 1   //1 for true
  b 99f       //dip lol
3:
  sub x22, x22, yOffset //LOOP BACK TO 1
  b 1b
98:
  //we made it here, so chances are it aint colliding
  mov x0, 0 //0 for false
99:
  ldr x22, [sp], 16     //load all of em off the stack and offset
  ldp x20, x21, [sp], 16
  ldr x30, [sp], 16
  ret                  //return and stuff :)

growBody:
  //x0 has the current ptr
  //x1 has the current size
  //x2 has the maxX, maxY ptr
  str x30, [sp, -16]!     //store linker to return
  mov x3, structSize
  add x1, x1, 1
  mul x1, x1, x3
  bl realloc
  ldr x30, [sp], 16       //load this to pop linker
  ret                     //return with new ptr in hand (hopefully)

.global main
main:
  stp x30, x19, [sp, -16]! //store x30 on the stack so we can return
  stp x20, x21, [sp, -16]! //store the rest on the stack so we can put stuff in em
  stp x22, x23, [sp, -16]!
  stp x24, x25, [sp, -16]!
  stp x26, x27, [sp, -16]!
  str x28, [sp, -16]!

  //this is nice.
  //x19 maxVals
  //x20 maxLength, won
  //x21, box
  //x22 stdscr
  //x23, apple
  //x24, bodyLength
  //x25, bodyArray
  //x26, direction
  //x27, reqDir

  bl initscr  //get stdscr
  mov x22, x0 //put that baby in x22

  //recall stdscr is in x0 ^
  mov x1, 1   //set arg 2 to true
  bl nodelay

  bl noecho   //hide player input

  mov x0, 0
  bl curs_set //make the cursor invisible

  mov x0, x22//set arg 1 to be stdscr
  bl getmaxx //get the maximum y value
  mov x1, x0
  mov x0, x22//put stdscr as arg 1
  bl getmaxy //get maxx (its in x0)
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
  mov x0, x0, lsr 1
  mov x1, x1, lsr 1
  bl initPosData
  mov x21, x0

  mov x0, 0     //set collumn to 0 for initial direction
  mov x1, -1    //set row to -1 for initiate direction <-- (its that way)
  bl initPosData
  mov x26, x0
  //set x26 to be our position data

  //reqDir
  mov x0, 0     //set it to 1 temporarily
  mov x1, x0    //set it to 1 (this *WILL* get overwritten immediatly)
  bl initPosData//initiate it
  mov x27, x0   //set x27 to reqDir

  //now we have the two registers for body
  //first: length
  //second: array
  mov x24, 5    //(its from 0 - 1)
  //thrilling.
  //next is for the array

  //we have functoin initBody(int bodysize)
  //recall x25 has the ptr to body
  mov x0, x24
  mov x1, x22
  bl initBody
  mov x25, x0 //it returns a pointer and we put it in x25

  //appal :)
  mov x0, 0
  mov x1, 0
  bl initPosData
  mov x23, x0
  mov x1, x19
  bl setPosRand

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

  bl getKeyPress
  cmp x0, QKeyCode //check if they're the same
  beq end          //if so go to end

  //get direction
  mov x1, x0  //the inputed key code put in arg 2
  mov x0, x27 //put reqDir in arg 1
  bl getDirFromKeyCode //set reqDir to be the coorosponding diretion

  //we have to check if the sum of them is = to 0 for both (that means they're opposites)
  ldr x0, [x26]
  ldr x1, [x26, yOffset]
  ldr x2, [x27]
  ldr x3, [x27, yOffset]

  cmp x2, 2            //if it is then we skip setting
  beq 1f               //here is the branch to 1f
  cmp x0, x3
  beq 1f
  cmp x1, x2
  beq 1f

  mov x0, x26
  mov x1, x27
  bl setPosDataToOtherData//and we sest dir to reqDir
  //that wasn't so hard was it? (it was)
1:
  //change position of box based on direction
  mov x0, x21 //load args
  mov x1, x26
  bl movePosDataByOtherPosData

  //wrap around the box
  mov x0, x21 //set the box as the object to loop
  mov x1, x19 //set the maxX and y as the max x and y
  bl wrapPosition

  //check if touching apple
  mov x0, x21
  mov x1, x23
  bl getColliding
  cbz x0, 2f

  //now we know its colliding
  mov x0, x25
  mov x1, x24
  str x24, [sp, -16]!
  mov x2, x19
  //bl growBody
  ldr x24, [sp], 16
  add x24, x24, 1
  mov x25, x0
2:
  //move body
  mov x0, x21
  mov x1, x25
  mov x2, x24
  bl moveBody

  mov x0, x21
  add x1, x25, structSize
  mov x2, x24
  //bl getCollidingWithBody
  mov x0, 0
  cbnz x0, end

  //x19 maxVals
  //x20 maxLength, won
  //x21, box
  //x22 stdscr
  //x23, apple
  //x24, bodyLength
  //x25, bodyArray
  //x26, direction
  //x27, reqDir

  //clear before printing/drawing
  bl clear

  //print appal
  mov x0, x23
  mov x1, applChar
  mov x2, x22
  bl drawPositionData

  //print body
  mov x0, x25
  mov x1, x24
  mov x2, x22
  bl printBody

  //print head
  mov x0, x21     //set the pos data to draw to be the box
  mov x1, headChar//set the character the head character
  mov x2, x22    //set the screen to draw on to be std screen
  bl drawPositionData//draw the position

  bl refresh     //refresh the screen

  bl delayTick    //delay the game by ~.1 seconds (its wrong)

  b gameLoop      //go back to gameLoop

end:

  mov x0, x22
  bl endwin //end the window

  mov x0, x19
  bl free

  mov x0, x20
  bl free

  mov x0, x21
  bl free

  //TODO fix the error that causes a core dump here
  //mov x0, x23
  //bl free

  mov x0, x25
  bl free

  mov x0, x26
  bl free

  mov x0, x27
  bl free


  //this is nice.
  //x19 maxVals
  //x20 maxLength, won
  //x21, box
  //x22 stdscr
  //x23, apple
  //x24, bodyLength
  //x25, bodyArray
  //x26, direction
  //x27, reqDir
  ldr x28, [sp], 16
  ldp x26, x27, [sp], 16
  ldp x24, x25, [sp], 16
  ldp x22, x23, [sp], 16
  ldp x20, x21, [sp], 16
  ldp x30, x19, [sp], 16
  mov x0, xzr   //ret 0
  ret
