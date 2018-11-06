# Realtime Raycasting on the Atari VCS

Due to popular demand, I decided to write a little bit of explanations on how I implemented Wolf3D raycasting algorithm on the stock Atari VCS console.

You can find a C++ program in directory raycaster-study which permitted to get a working POC of the expected VCS result using SDL library on Mac, using "8bit compilable" code, and debuggable in a C++ compiler. build.sh compiles and executable is "play". I let the play binary in the folder but you might need to brew install sdl to run it if you don't have SDL. It is based on source code from Lode Vandevenne and his tutorials about raycasting. You can find them here: [https://lodev.org/cgtutor/raycasting.html](https://lodev.org/cgtutor/raycasting.html)

An interactive VCS demo is in directory demo-raycaster. There is a script build.sh (for Mac) which permits to launch it directly. You can use the joypad to move in the world.

I will not explain here how the raycast algorithm works, as there are already some good tutorials on internet. I will just give some credits to Richard Wilson, who has made a crazy good POC of Wolf3D on the Amstrad CPC 6128, and to the creators of the original Wolfenstein3d PC DOS game, who open sourced their source code, and without who I would not have been able to implement that algorithm. I updated the algorithm to only need one kind of multiplications: 16bit (unsigned 8bit value with an 8bit fract) * unsigned 8bit fract multiplicand -> 16bit result (unsigned 8bit value with an 8bit fract).

Also, for the display of the raycasting, I credit Joe Musashi from AtariAge forum, it was his idea to simulate horizontal and vertical walls of the map, with two different colors, by displaying some playfield data with two different colors in alternance. I reused this idea; I think this method looks nice.

## How the raycasting result is stored

The raycasting calculates vertical lines (1 ray -> 1 line). For each line we store the color and the height. For each rendered frame, 32 rays are fired. A vertical line can only be black or white, so we need 1 bit to know the color of 1 line. So, for 32 lines, we use 4 bytes to store the color result. We store the height of the lines from the middle of the rendered frame to their top. The value varies between 0 and 15\. Hence, we need 4 bits to store the height of one line. 32 vertical lines -> 16 bytes. Also, we store the min and max of those calculated heights. So, 1 more byte for this "minmax height" information. Total of the raycast output data: 4 + 16 + 1 = 21 bytes.

## How the display is made

The playfield is in reflect mode. So, to display the 32 columns of the raycast, 4 bytes will be needed (PF1 - PF2 - PF2 - PF1). Only one inconvenient: the 2nd STA PF2 of each line of display has to end executing at the 48th CPU cycle of the line (reminder: we have 76 CPU cycles per line. 48th cycle happens when the electron beam reaches the middle of the screen).

We have 4 bytes of playfield data for each line group of the display. Each line group consists of 3 lines: 1 line for the walls with white playfield color, 1 line for the walls with black playfield color, and one blank line we use to prepare the 4 bytes of playfield data of the next line group.

To display a white line, we do this operation:

<pre>        LDA ColorsData     ; color mask
        EOR #$FF
        AND TempPF0     ; playfield data
        sta PF1    
</pre>

And to display a black line, we do this operation:

<pre>        LDA ColorsData
        AND TempPF0
        sta PF1 
</pre>

Once we reach the vertical middle of the screen, we just need to display the mirrored version of the upper half of the display, and we are done.

## How the display data is stored

Let's check the RAM now.

We use 11 bytes for TIATracker player. 2 bytes for demo frame counter. To have fastest ever possible multiplications, we reserve 24 bytes of multiplication table pointers (yeah, speed has a cost...)

6 bytes of "global" raycast variables:

<pre>RAYCASTER       equ MULTEMPS_END
posx            equ RAYCASTER     ; .word
posy            equ RAYCASTER + 2 ; .word
startAng        equ RAYCASTER + 4 ; .byte 
numCol          equ RAYCASTER + 5 ; .byte (-16;+15)
RAYCASTER_END   equ RAYCASTER + 6
</pre>

12 bytes of variables used for the raycast computation.

21 bytes are used for the raycast output.

So, wait. 16 line groups, 4 bytes of data per line. That makes 64 bytes. 11 + 2 + 24 + 6 + 12 + 21 + 64 + let's say 4 bytes of stack: 144 bytes. Ouch, not enough space :( we have only 128 bytes of precious RAM. Welcome to the limitations of the VCS... We can not store the whole playfield data of the final display in the memory.

Hereafter, let's call the 4 bytes of the playfield data: PF0, PF1, PF2 and PF3\.

So, we use delta compression. Instead of storing the whole playfield data, we store the playfield data of the first line group. Then we store only the differences from a line group, to the next. Those differences are stored in a "double linked list" of deltas.

Each delta consist of two elements.

First element is one byte. In that byte, 4 bits are used to indicate if PF0, PF1, PF2 and PF3 are changing value or not, from current line group to next. And 4 bits are used to indicate if PF0, PF1, PF2 and PF3 are changing value or not, from current line group to previous. This is the double link.

Second element is a list of playfield data delta. Length is varying from 0 byte to 4 bytes. Each delta is a value to EOR (Exclusive OR) with the current value of PF0, PF1, PF2 or PF3 to get its next value.

So, after having drawn a line group, we calculate the playfield data with some EORs, and we are ready to display the next one.

<h2how to="" display="" the="" second="" part="" of="" screen<="" h2="">

Well, remember the first byte of the delta ? The second "link" which permits to go from current playfield data to previous. We use it to replay the EORs we have done until reaching the end of the deltas, in reverse order. Hence, we end with the initial playfield data and drawing the whole frame is finished.

In practice, the "ready to display" raycast output averages around 35 bytes if I remember well. So, we fit in the VCS memory. Pretty cool.

## How to convert from the raycast output to the ready to display ?

For each line group, we calculate the playfield data and we compare with the previous data. Then we store the differences.

Basically, in the code of interactive raycast demo I give, I use this kind of code:

<pre>        LDA RayCasterOut+17        ; A contains heights of two consecutive vertical lines
        TAY
        LDX .HIGHQUAD,y         ; Get height of line 1 in X
        CPX ConverterIterator   ; Compare with index of line group being computed
        ROL TempPF2             ; If Height of line 1 > currentHeight, output one 1 bit in temp playfield data, otherwise output a 0
        AND #15                 ; Get height of line 2 in X
        CMP ConverterIterator   ; Compare with index of line group being computed
        ROL TempPF2             ; If Height of line 2 > currentHeight, output one 1 bit in temp playfield data, otherwise output a 0
</pre>

In the final demo, I needed more speed for that part, so at the cost of silly data tables (well, after all, it was for the Silly Venture...), I managed to output playfield data per groups of two bits at a time.

<pre>        LDX #$FF                ; init Playfield data byte

        LDY raycastoutput       ; load column0Height and column1Height
        LDA PFOut76,y           ; A = bit 7: if column0Height == 15 then 1 else 0; bit 6: if column1Height == 15 then 1 else 0; other bits: 1
        AXS #0                  ; X = X & A
        LDA IncrementHeight,y   
        STA raycastoutput       ; overwrites raycast output: if column0Height < 15, column0Height++; if column1Height < 15, column1Height++;

        LDY raycastoutput+1     ; load column2Height and column3Height
        LDA PFOut54,y           ; A = bit 5: if column2Height == 15 then 1 else 0; bit 4: if column3Height == 15 then 1 else 0; other bits: 1
        AXS #0                  ; X = X & A
        LDA IncrementHeight,y
        STA raycastoutput+1\.    ; overwrites raycast output: if column2Height < 15, column2Height++; if column3Height < 15, column3Height++;

        LDY raycastoutput+2     ; load column4Height and column5Height
        LDA PFOut32,y           ; A = bit 3: if column4Height == 15 then 1 else 0; bit 2: if column5Height == 15 then 1 else 0; other bits: 1
        AXS #0                  ; X = X & A
        LDA IncrementHeight,y
        STA raycastoutput+2     ; overwrites raycast output: if column4Height < 15, column4Height++; if column5Height < 15, column5Height++;

        LDY raycastoutput+3     ; load column6Height and column7Height
        LDA PFOut10,y           ; A = bit 1: if column6Height == 15 then 1 else 0; bit 0: if column7Height == 15 then 1 else 0; other bits: 1
        AXS #0                  ; X = X & A
        LDA IncrementHeight,y
        STA raycastoutput+3     ; overwrites raycast output: if column6Height < 15, column6Height++; if column7Height < 15, column7Height++;

        STX TempPF0             ; finished generating 8 bits of playfield
</pre>

And that's it I think. I hoped this reading was interesting and enjoyable as much as it was for me to code that effect on the VCS.

Kezax/Dentifrice

</h2how>
