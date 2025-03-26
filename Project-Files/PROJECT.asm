bs struct
	xup db 0
	xdown db 0
	yup db 0
	ydown db 0
	colour db 0
	flag db 0
	special db 0  ; 0 for boundary
	;1 for normal
	; 2 for permanent flags
	
bs ends



.model small
.stack 0100h
screenclear macro p1
mov ah, 0
	mov al, 12h    
	int 10h
	
endm



soundbeep macro p1



mov al,182
out 43h,al
mov ax,p1

out 42h,al
mov al,ah
out 42h,al
in al,61h

or al,00000011b
out 61h,al
mov bx,3

pauses:
		mov cx,65535
pauses2:
		dec cx
		jne pauses2
		dec bx
		jne pauses
		in al,61h
		
		and al,11111100b
		out 61h,al
		




endm

.data
fname db "Scores.txt $"
handle dw ?
buffer db 1000 dup(?),'$' 
winstrings db "Press BACKSPACE to go back to Main Menu.$ "
gamewww db 0
stringname db "Please Enter Your Name: $"
loopcmp dw 15
loopdef dw 7
string1 db "INSTRUCTIONS : "
string2 db "1) Press RIGHT KEY to move pad right. $"
string3 db "2) Press LEFT KEY to move pad left. $"
string4 db "3) Hit the block to BREAK IT. $"
string5 db "4) Breaking gives 10 SCORE. $"
string6 db "5) CYAN BLOCKS never breaks. $"
string7 db "6) SPECIAL BLOCKS gives POWERUPS. $"
string8 db "7) BREAK EM ALL TO WIN!!! $"


stringlvl1 db "1) Press 1 for LEVEL 1. $"
stringlvl2 db "2) Press 2 for LEVEL 2. $"
stringlvl3 db "3) Press 3 for LEVEL 3. $"


	looptimer db 45
	gameover db 45
	seconds db 48
	seconds1 db 48
	minutess db 48
	flaglives db 1
	locheart db 35
	heartiheart dw 3
	tempscores db 0
	xfacts db 0
	yfacts db 0
	xsign db 1
	ysign db 1
	signfacts db 0
	loopcounter dw 0
	; 4,14,10,9,1,5

	scorestr db "SCORE: $"
	scorenum db 0

	timestr db "TIME: $"
	timeval db 40

	livestr db "LIVES: $"
	liveval db 3

	nameStr db "NAME: $"
	nameVal db 10 dup()
	

	tempStr2 db "         $"

	levelStr db "LEVEL: $"
	levelVal db 1
	
	
	blockVal bs <5,5,0,100,12,0,0>,<5,30,78,79,12,0,0>,<5,30,0,1,12,0,0>
			 bs < 7, 7,3,13,4,0,0>,< 7, 7,15,25,14,0,0>,< 7, 7,27,37,10,0,0>,< 7, 7,39,49,9,0,0>,< 7, 7,51,61,1,0,0>,< 7, 7,63,73,5,0,0>
			 bs < 9, 9,6,16,14,0,0>,< 9, 9,18,28,10,0,0>,< 9, 9,30,40,9,0,0>,< 9, 9,42,52,1,0,1>,< 9, 9,54,64,5,0,0>,< 9, 9,66,76,4,0,0>
			 bs <11,11,3,13,10,0,0>,<11,11,15,25,9,0,1>,<11,11,27,37,1,0,2>,<11,11,39,49,5,0,0>,<11,11,51,61,4,0,1>,<11,11,63,73,14,0,0>
			 bs <13,13,6,16,9,0,0>,<13,13,18,28,1,0,0>,<13,13,30,40,5,0,0>,<13,13,42,52,4,0,1>,<13,13,54,64,14,0,0>,<13,13,66,76,10,0,0>
			 bs <15,15,3,13,1,0,0>,<15,15,15,25,5,0,1>,<15,15,27,37,4,0,1>,<15,15,39,49,14,0,0>,<15,15,51,61,10,0,0>,<15,15,63,73,9,0,0>
			 			
	pad bs <28,28,30,40,0FH,0,0>
	ball bs <34,35,27,27,0FH,0,0>
	blockhits db 0
	numblocks dw 30
	permb dw 6
	
	funcball dw 0
	
	func db 0
.code

	mov ax,@DATA
	mov ds,ax
	mov ax,0

	mov ah, 0
	mov al, 12h    
	int 10h
	
	jmp main


writefile macro p1,p2


; assuming "bx" holds the file handle

mov ah, 42h  ; "lseek"
mov al, 2    ; position relative to end of file
mov cx, 0    ; offset MSW
mov dx, 0    ; offset LSW
int 21h

mov ah, 40h ; service to write to a file
mov bx, p1
mov cx, lengthof p2 ;string length.

mov dx, offset p2
int 21h




endm


charcaterMake macro p1,row,column,cc

;setting cursor position
mov ah, 2
mov dh, row    ;row
mov dl, column     ;column
int 10h

mov al,p1    ;ASCII code of Character 
mov bx,0
mov bl,cc   ;Green color
mov cx,1       ;repetition count
mov ah,09h
int 10h


endm


ballmaking proc
mov cx,0ffffh
del:
loop del 
		
		mov ah, 6
		mov al, 0
		mov bh,0
		mov ch, ball.yup
		mov cl, ball.xup 
		mov dh, ball.ydown		
		mov dl, ball.xdown 
		int 10h
		
		
		mov ah, 6
		mov al, 0
		
		cmp xsign,1
		jne signx
		sub cl,xfacts
		sub dl,xfacts
		signxback:
		cmp ysign,1
		jne signy 
		sub ch,yfacts	
		sub dh,yfacts
		signyback:
		mov bh, 12   
		int 10h
		
		mov ball.xup,cl
		mov ball.yup,ch  
		mov ball.xdown,dl	
		mov ball.ydown,dh 
		ret

signx:
		add cl,xfacts
		add dl,xfacts
		jmp signxback

signy:
		add ch,yfacts	
		add dh,yfacts
		jmp signyback


ballmaking endp




createfile proc					;to create

;to create
mov ah, 3ch ;service to create a file
mov cx, 0
mov dx, offset fname
int 21h

ret
createfile endp

openfile proc					;to open


;to open
mov ah,3dh ; 3dh of dos services opens a file.
mov al,2 ; 0 - for reading. 1 - for writing. 2 - both
mov dx,offset fname ; make a pointer to the filename
int 21h ; call dos
mov handle,ax


ret
openfile endp


selectionscreen proc
mov ah, 0
mov al, 12h
int 10h
charcaterMake ' ',10,30,12

intipinti:
mov si,0
		mov dl,5

		lvl1s:
		
			mov ah, 2
			mov dh, 7 ;row
			int 10h

			mov al,stringlvl1[si]    ;ASCII code of Character 
			cmp al,'$'
			je lvl1end
			mov bl,1111b   
			mov ah,09h
	     ;color
			int 10h
			inc si
			inc dl
			jmp lvl1s
		
		lvl1end:


mov si,0
		mov dl,5

		lvl2s:
		
			mov ah, 2
			mov dh, 8 ;row
			int 10h

			mov al,stringlvl2[si]    ;ASCII code of Character 
			cmp al,'$'
			je lvl2end
			mov bl,1111b   
			mov ah,09h
	     ;color
			int 10h
			inc si
			inc dl
			jmp lvl2s
		
		lvl2end:




mov si,0
		mov dl,5

		lvl3s:
		
			mov ah, 2
			mov dh, 9 ;row
			int 10h

			mov al,stringlvl3[si]    ;ASCII code of Character 
			cmp al,'$'
			je lvl3end
			mov bl,0fh   
			mov ah,09h
	     ;color
			int 10h
			inc si
			inc dl
			jmp lvl3s
		
		lvl3end:


mov ah,1
int 16h
mov ah,0
int 16h

.if al=='1'
	mov levelVal,1
	mov loopcmp,14
.elseif al=='2'
	mov levelVal,2
	mov loopcmp,9
.elseif al=='3'
	mov levelVal,3
	mov loopcmp,7
.else
	jmp intipinti
.endif


ret
selectionscreen endp




losepage proc
mov gameover,0
mov ah, 0
mov al, 12h
int 10h
loseagain:
charcaterMake 'Y',10,30,12
charcaterMake 'O',10,31,12
charcaterMake 'U',10,32,12
charcaterMake ' ',10,33,12
charcaterMake 'L',10,34,12
charcaterMake 'O',10,35,12
charcaterMake 'S',10,36,12
charcaterMake 'E',10,37,12
charcaterMake ' ',10,38,12
charcaterMake ':',10,39,12
charcaterMake '(',10,40,12


charcaterMake 3,10,28,1111b



mov si,0
		mov dl,5

		win1s:
		
			mov ah, 2
			mov dh, 26 ;row
			int 10h

			mov al,winstrings[si]    ;ASCII code of Character 
			cmp al,'$'
			je win1send
			mov bl,1111b   
			mov ah,09h
	     ;color
			int 10h
			inc si
			inc dl
			jmp win1s
		
		win1send:



mov ah,1
int 16h
mov ah,0
int 16h

cmp al,08
jne agains3

jmp exitlose
agains3:
jmp loseagain



exitlose:
ret





losepage endp

winspage proc
mov ah, 0
mov al, 12h
int 10h

winsagain:
charcaterMake 'Y',10,30,15
charcaterMake 'O',10,31,9
charcaterMake 'U',10,32,11
charcaterMake ' ',10,33,13
charcaterMake 'W',10,34,14
charcaterMake 'O',10,35,15
charcaterMake 'N',10,36,10
charcaterMake 'S',10,38,12
charcaterMake 'E',10,39,11
charcaterMake 'N',10,40,15
charcaterMake 'P',10,41,13
charcaterMake 'A',10,42,14
charcaterMake 'I',10,43,14


charcaterMake 3,10,28,12

charcaterMake 3,10,45,12


mov si,0
		mov dl,5

		win1s:
		
			mov ah, 2
			mov dh, 26 ;row
			int 10h

			mov al,winstrings[si]    ;ASCII code of Character 
			cmp al,'$'
			je win1send
			mov bl,1111b   
			mov ah,09h
	     ;color
			int 10h
			inc si
			inc dl
			jmp win1s
		
		win1send:



mov ah,1
int 16h
mov ah,0
int 16h

cmp al,08
jne agains2

jmp exitwins
agains2:
jmp winsagain



exitwins:
ret







winspage endp




insernamepage proc
mov ah, 0
mov al, 12h
int 10h

mov si,0
		mov dl,5

		line1:
		
			mov ah, 2
			mov dh, 5+3 ;row
			int 10h

			mov al,stringname[si]    ;ASCII code of Character 
			cmp al,'$'
			je line1end
			mov bl,1111b   
			mov ah,09h
	     ;color
			int 10h
			inc si
			inc dl
			jmp line1
		
		line1end:






mov ah, 6
mov al, 0
mov bh, 12     ;color
mov ch, 6	     ;top row of window
mov cl, 4     ;left most column of window
mov dh, 6     ;Bottom row of window
mov dl, 28     ;Right most column of window
int 10h


mov ah, 6
mov al, 0
mov bh, 12     ;color
mov ch, 10	     ;top row of window
mov cl, 28     ;left most column of window
mov dh, 10     ;Bottom row of window
mov dl, 52     ;Right most column of window
int 10h

mov si , offset nameVal
inputnames:
	mov ah,01h
	int 21h
	cmp al,13
	je display1n
	cmp al,08
	jne nextts
	dec si
	jmp inputnames
	nextts:
	mov [si],al
	inc si
	jmp inputnames
	
display1n:
inc si
mov al,'$'
mov [si],al

ret
insernamepage endp



instuctionpage proc

mov ah, 0
mov al, 12h
int 10h
instruagain:
charcaterMake 'I',3,30,15
charcaterMake 'N',3,31,9
charcaterMake 'S',3,32,11
charcaterMake 'T',3,33,13
charcaterMake 'R',3,34,14
charcaterMake 'U',3,35,15
charcaterMake 'C',3,36,10
charcaterMake 'T',3,37,12
charcaterMake 'I',3,38,11
charcaterMake 'O',3,39,15
charcaterMake 'N',3,40,13
charcaterMake 'S',3,41,14

mov si,0
		mov dl,5

		line1:
		
			mov ah, 2
			mov dh, 5+3 ;row
			int 10h

			mov al,string2[si]    ;ASCII code of Character 
			cmp al,'$'
			je line1end
			mov bl,1111b   
			mov ah,09h
	     ;color
			int 10h
			inc si
			inc dl
			jmp line1
		
		line1end:





mov si,0
		mov dl,5

		line2:
		
			mov ah, 2
			mov dh, 7+3 ;row
			int 10h

			mov al,string3[si]    ;ASCII code of Character 
			cmp al,'$'
			je line2end
			mov bl,1111b   
			mov ah,09h
	     ;color
			int 10h
			inc si
			inc dl
			jmp line2
		
		line2end:





mov si,0
		mov dl,5

		line3:
		
			mov ah, 2
			mov dh, 9+3 ;row
			int 10h

			mov al,string4[si]    ;ASCII code of Character 
			cmp al,'$'
			je line3end
			mov bl,1111b   
			mov ah,09h
	     ;color
			int 10h
			inc si
			inc dl
			jmp line3
		
		line3end:




mov si,0
		mov dl,5

		line4:
		
			mov ah, 2
			mov dh, 11+3;row
			int 10h

			mov al,string5[si]    ;ASCII code of Character 
			cmp al,'$'
			je line4end
			mov bl,1111b   
			mov ah,09h
	     ;color
			int 10h
			inc si
			inc dl
			jmp line4
		
		line4end:





mov si,0
		mov dl,5

		line5:
		
			mov ah, 2
			mov dh, 13+3;row
			int 10h

			mov al,string6[si]    ;ASCII code of Character 
			cmp al,'$'
			je line5end
			mov bl,1111b   
			mov ah,09h
	     ;color
			int 10h
			inc si
			inc dl
			jmp line5
		
		line5end:



mov si,0
		mov dl,5

		line6:
		
			mov ah, 2
			mov dh, 15 +3;row
			int 10h

			mov al,string7[si]    ;ASCII code of Character 
			cmp al,'$'
			je line6end
			mov bl,1111b   
			mov ah,09h
	     ;color
			int 10h
			inc si
			inc dl
			jmp line6
		
		line6end:




mov si,0
		mov dl,5

		line7:
		
			mov ah, 2
			mov dh, 17 +3;row
			int 10h

			mov al,string8[si]    ;ASCII code of Character 
			cmp al,'$'
			je line7end
			mov bl,1111b   
			mov ah,09h
	     ;color
			int 10h
			inc si
			inc dl
			jmp line7
		
		line7end:



mov ah, 6
mov al, 0
mov bh, 12     ;color
mov ch, 5	     ;top row of window
mov cl, 28     ;left most column of window
mov dh, 5     ;Bottom row of window
mov dl, 43     ;Right most column of window
int 10h


mov ah, 6
mov al, 0
mov bh, 12     ;color
mov ch, 1	     ;top row of window
mov cl, 28     ;left most column of window
mov dh, 1     ;Bottom row of window
mov dl, 43     ;Right most column of window
int 10h


mov ah,1
int 16h
mov ah,0
int 16h

cmp al,08
jne agains

jmp exitinstuc
agains:
jmp instruagain



exitinstuc:
ret

instuctionpage endp






starts proc

screenclear 0

mov ah, 6
mov al, 0
mov bh, 1111b     ;color
mov ch, 20    ;top row of window
mov cl, 0    ;left most column of window
mov dh, 40     ;Bottom row of window
mov dl,80    ;Right most column of window
int 10h

add si,4

mov ah, 6
	mov al, 0
	mov bh, 12     ;color
	mov ch, 2     ;top row of window
	mov cl, 0     ;left most column of window
	mov dh, 30   ;Bottom row of window
	mov dl, 1     ;Right most column of window
	int 10h

	
	mov ah, 6
	mov al, 0
	mov bh, 12     ;color
	mov ch, 2     ;top row of window
	mov cl, 78     ;left most column of window
	mov dh, 30   ;Bottom row of window
	mov dl, 79     ;Right most column of window
	int 10h



	mov ah, 6
	mov al, 0
	mov bh, 12     ;color
	mov ch, 2     ;top row of window
	mov cl, 0     ;left most column of window
	mov dh, 2   ;Bottom row of window
	mov dl, 100    ;Right most column of window
	int 10h



	mov ah, 6
	mov al, 0
	mov bh, 12     ;color
	mov ch, 29   ;top row of window
	mov cl, 1     ;left most column of window
	mov dh, 29   ;Bottom row of window
	mov dl, 77    ;Right most column of window
	int 10h
	
	
mov bx,50
mov si,100

l1:
MOV CX, bx    
MOV DX, 92    
MOV AL, 12  
MOV AH, 0CH 
INT 10H
mov cx,si
dec si
inc bx
loop l1

mov bx,92
mov si,20

l2:
MOV CX, 50    
MOV DX, bx    
MOV AL, 12  
MOV AH, 0CH 
INT 10H
mov cx,si
dec si
inc bx
loop l2


mov bx,50
mov si,100

l3:
MOV CX, bx    
MOV DX, 112    
MOV AL, 12  
MOV AH, 0CH 
INT 10H
mov cx,si
dec si
inc bx
loop l3



mov bx,92
mov si,20

l4:
MOV CX, 150    
MOV DX, bx    
MOV AL, 12  
MOV AH, 0CH 
INT 10H
mov cx,si
dec si
inc bx
loop l4



mov ah, 2
mov dh, 6 ;row
mov dl, 10     ;column
int 10h

mov al,'S'    ;ASCII code of Character 
mov bx,0
mov bl,1111b   ;Green color
mov cx,1  
mov ah,09h
int 10h

mov ah, 2
mov dh, 6 ;row
mov dl, 11      ;column
int 10h

mov al,'T'    ;ASCII code of Character 
mov bx,0
mov bl,0100b   ;Green color
mov cx,1  
mov ah,09h
int 10h


mov ah, 2
mov dh, 6 ;row
mov dl, 12      ;column
int 10h

mov al,'A'    ;ASCII code of Character 
mov bx,0
mov bl,1010b   ;Green color
mov cx,1  
mov ah,09h
int 10h



mov ah, 2
mov dh, 6 ;row
mov dl, 13      ;column
int 10h

mov al,'R'    ;ASCII code of Character 
mov bx,0
mov bl,0100b   ;Green color
mov cx,1  
mov ah,09h
int 10h

	

mov ah, 2
mov dh, 6 ;row
mov dl, 14     ;column
int 10h

mov al,'T'    ;ASCII code of Character 
mov bx,0
mov bl,1111b   ;Green color
mov cx,1  
mov ah,09h
int 10h


mov bx,50
mov si,100

l11:
MOV CX, bx    
MOV DX, 140    
MOV AL, 12  
MOV AH, 0CH 
INT 10H
mov cx,si
dec si
inc bx
loop l11

mov bx,140
mov si,20

l22:
MOV CX, 50    
MOV DX, bx    
MOV AL, 12  
MOV AH, 0CH 
INT 10H
mov cx,si
dec si
inc bx
loop l22


mov bx,50
mov si,100

l33:
MOV CX, bx    
MOV DX, 160    
MOV AL, 12  
MOV AH, 0CH 
INT 10H
mov cx,si
dec si
inc bx
loop l33



mov bx,140
mov si,20

l44:
MOV CX, 150    
MOV DX, bx    
MOV AL, 12  
MOV AH, 0CH 
INT 10H
mov cx,si
dec si
inc bx
loop l44



mov ah, 2
mov dh, 9 ;row
mov dl, 7     ;column
int 10h

mov al,'I'    ;ASCII code of Character 
mov bx,0
mov bl,0100b   ;Green color
mov cx,1  
mov ah,09h
int 10h

mov ah, 2
mov dh, 9 ;row
mov dl, 8      ;column
int 10h

mov al,'N'    ;ASCII code of Character 
mov bx,0
mov bl,1111b   ;Green color
mov cx,1  
mov ah,09h
int 10h


mov ah, 2
mov dh, 9 ;row
mov dl, 9      ;column
int 10h

mov al,'S'    ;ASCII code of Character 
mov bx,0
mov bl,1010b   ;Green color
mov cx,1  
mov ah,09h
int 10h



mov ah, 2
mov dh, 9 ;row
mov dl, 10      ;column
int 10h

mov al,'T'    ;ASCII code of Character 
mov bx,0
mov bl,0100b   ;Green color
mov cx,1  
mov ah,09h
int 10h



mov ah, 2
mov dh, 9 ;row
mov dl, 11     ;column
int 10h

mov al,'R'    ;ASCII code of Character 
mov bx,0
mov bl,1111b   ;Green color
mov cx,1  
mov ah,09h
int 10h


mov ah, 2
mov dh, 9 ;row
mov dl, 12     ;column
int 10h

mov al,'U'    ;ASCII code of Character 
mov bx,0
mov bl,1010b   ;Green color
mov cx,1  
mov ah,09h
int 10h


mov ah, 2
mov dh, 9 ;row
mov dl, 13     ;column
int 10h

mov al,'C'    ;ASCII code of Character 
mov bx,0
mov bl,0100b   ;Green color
mov cx,1  
mov ah,09h
int 10h


mov ah, 2
mov dh, 9 ;row
mov dl, 14     ;column
int 10h

mov al,'T'    ;ASCII code of Character 
mov bx,0
mov bl,1111b   ;Green color
mov cx,1  
mov ah,09h
int 10h


mov ah, 2
mov dh, 9 ;row
mov dl, 15     ;column
int 10h

mov al,'I'    ;ASCII code of Character 
mov bx,0
mov bl,1010b   ;Green color
mov cx,1  
mov ah,09h
int 10h


mov ah, 2
mov dh, 9 ;row
mov dl, 16     ;column
int 10h

mov al,'O'    ;ASCII code of Character 
mov bx,0
mov bl,0100b   ;Green color
mov cx,1  
mov ah,09h
int 10h


mov ah, 2
mov dh, 9 ;row
mov dl, 17     ;column
int 10h

mov al,'N'    ;ASCII code of Character 
mov bx,0
mov bl,1111b   ;Green color
mov cx,1  
mov ah,09h
int 10h


	
	
mov bx,50
mov si,100

l111:
MOV CX, bx    
MOV DX, 210    
MOV AL, 12  
MOV AH, 0CH 
INT 10H
mov cx,si
dec si
inc bx
loop l111

mov bx,190
mov si,20

l222:
MOV CX, 50    
MOV DX, bx    
MOV AL, 12  
MOV AH, 0CH 
INT 10H
mov cx,si
dec si
inc bx
loop l222


mov bx,50
mov si,100

l333:
MOV CX, bx    
MOV DX, 190    
MOV AL, 12  
MOV AH, 0CH 
INT 10H
mov cx,si
dec si
inc bx
loop l333



mov bx,190
mov si,20

l444:
MOV CX, 150    
MOV DX, bx    
MOV AL, 12  
MOV AH, 0CH 
INT 10H
mov cx,si
dec si
inc bx
loop l444



mov ah, 2
mov dh, 12 ;row
mov dl, 10     ;column
int 10h

mov al,'S'    ;ASCII code of Character 
mov bx,0
mov bl,1010b   ;Green color
mov cx,1  
mov ah,09h
int 10h

mov ah, 2
mov dh, 12 ;row
mov dl, 11      ;column
int 10h

mov al,'C'    ;ASCII code of Character 
mov bx,0
mov bl,1111b   ;Green color
mov cx,1  
mov ah,09h
int 10h


mov ah, 2
mov dh, 12 ;row
mov dl, 12      ;column
int 10h

mov al,'O'    ;ASCII code of Character 
mov bx,0
mov bl,0100b   ;Green color
mov cx,1  
mov ah,09h
int 10h



mov ah, 2
mov dh, 12 ;row
mov dl, 13      ;column
int 10h

mov al,'R'    ;ASCII code of Character 
mov bx,0
mov bl,1010b   ;Green color
mov cx,1  
mov ah,09h
int 10h

	

mov ah, 2
mov dh, 12 ;row
mov dl, 14     ;column
int 10h

mov al,'E'    ;ASCII code of Character 
mov bx,0
mov bl,1111b   ;Green color
mov cx,1  
mov ah,09h
int 10h






mov ah, 2
mov dh, 15 ;row
mov dl, 10     ;column
int 10h

mov al,'E'    ;ASCII code of Character 
mov bx,0
mov bl,1111b   ;Green color
mov cx,1  
mov ah,09h
int 10h

mov ah, 2
mov dh, 15 ;row
mov dl, 11      ;column
int 10h

mov al,'X'    ;ASCII code of Character 
mov bx,0
mov bl,1010b   ;Green color
mov cx,1  
mov ah,09h
int 10h


mov ah, 2
mov dh, 15 ;row
mov dl, 12      ;column
int 10h

mov al,'I'    ;ASCII code of Character 
mov bx,0
mov bl,0100b   ;Green color
mov cx,1  
mov ah,09h
int 10h



mov ah, 2
mov dh, 15 ;row
mov dl, 13      ;column
int 10h

mov al,'T'    ;ASCII code of Character 
mov bx,0
mov bl,1111b   ;Green color
mov cx,1  
mov ah,09h
int 10h



	
	
mov bx,50
mov si,100

l1111:
MOV CX, bx    
MOV DX, 256    
MOV AL, 12  
MOV AH, 0CH 
INT 10H
mov cx,si
dec si
inc bx
loop l1111

mov bx,240
mov si,21

l2222:
MOV CX, 50    
MOV DX, bx    
MOV AL, 12  
MOV AH, 0CH 
INT 10H
mov cx,si
dec si
inc bx
loop l2222


mov bx,50
mov si,100

l3333:
MOV CX, bx    
MOV DX, 238    
MOV AL, 12  
MOV AH, 0CH 
INT 10H
mov cx,si
dec si
inc bx
loop l3333


mov bx,238
mov si,20

l4444:
MOV CX, 150    
MOV DX, bx    
MOV AL, 12  
MOV AH, 0CH 
INT 10H
mov cx,si
dec si
inc bx
loop l4444
	
	mov ah, 6
	mov al, 0
	mov bh, 1110b     ;color
	mov ch, 13    ;top row of window
	mov cl, 45     ;left most column of window
	mov dh, 14   ;Bottom row of window
	mov dl, 70     ;Right most column of window
	int 10h
	
	mov ah, 6
	mov al, 0
	mov bh, 0100b     ;color
	mov ch, 6     ;top row of window
	mov cl, 45     ;left most column of window
	mov dh, 12   ;Bottom row of window
	mov dl, 70     ;Right most column of window
	int 10h
	
	
	mov ah, 6
	mov al, 0
	mov bh, 0000b     ;color
	mov ch, 7     ;top row of window
	mov cl, 50     ;left most column of window
	mov dh, 8   ;Bottom row of window
	mov dl, 51     ;Right most column of window
	int 10h
	
	mov ah, 6
	mov al, 0
	mov bh, 0000b     ;color
	mov ch, 7     ;top row of window
	mov cl, 54     ;left most column of window
	mov dh, 8   ;Bottom row of window
	mov dl, 55     ;Right most column of window
	int 10h
	
	mov ah, 6
	mov al, 0
	mov bh, 0000b     ;color
	mov ch, 7     ;top row of window
	mov cl, 54     ;left most column of window
	mov dh, 7   ;Bottom row of window
	mov dl, 59     ;Right most column of window
	int 10h
	
	mov ah, 6
	mov al, 0
	mov bh, 0000b     ;color
	mov ch, 9     ;top row of window
	mov cl, 50     ;left most column of window
	mov dh, 9   ;Bottom row of window
	mov dl, 58     ;Right most column of window
	int 10h


	
	mov ah, 6
	mov al, 0
	mov bh, 0000b     ;color
	mov ch, 10     ;top row of window
	mov cl, 54     ;left most column of window
	mov dh, 11   ;Bottom row of window
	mov dl, 55     ;Right most column of window
	int 10h
	
	
	mov ah, 6
	mov al, 0
	mov bh, 0000b     ;color
	mov ch, 9     ;top row of window
	mov cl, 58     ;left most column of window
	mov dh, 11   ;Bottom row of window
	mov dl, 59     ;Right most column of window
	int 10h
	
	
	mov ah, 6
	mov al, 0
	mov bh, 0000b     ;color
	mov ch, 11     ;top row of window
	mov cl, 50     ;left most column of window
	mov dh, 11   ;Bottom row of window
	mov dl, 53     ;Right most column of window
	int 10h

	


	
	mov ah, 6
	mov al, 0
	mov bh, 0000b     ;color
	mov ch, 22     ;top row of window
	mov cl, 19     ;left most column of window
	mov dh, 22   ;Bottom row of window
	mov dl, 23     ;Right most column of window
	int 10h

	


mov ah, 2
mov dh, 22 ;row
mov dl, 21      ;column
int 10h


mov al,'B'    ;ASCII code of Character 
mov bl,1010b   ;Green color
mov cx,1  
mov ah,09h
int 10h



	mov ah, 6
	mov al, 0
	mov bh, 0000b     ;color
	mov ch, 22     ;top row of window
	mov cl, 25     ;left most column of window
	mov dh, 22   ;Bottom row of window
	mov dl, 29     ;Right most column of window
	int 10h

	


mov ah, 2
mov dh, 22 ;row
mov dl, 27      ;column
int 10h


mov al,'R'    ;ASCII code of Character 
mov bl,1111b   ;Green color
mov cx,1  
mov ah,09h
int 10h





	mov ah, 6
	mov al, 0
	mov bh, 0000b     ;color
	mov ch, 22     ;top row of window
	mov cl, 31     ;left most column of window
	mov dh, 22   ;Bottom row of window
	mov dl, 35     ;Right most column of window
	int 10h

	


mov ah, 2
mov dh, 22 ;row
mov dl, 33      ;column
int 10h


mov al,'I'    ;ASCII code of Character 
mov bl,0100b   ;Green color
mov cx,1  
mov ah,09h
int 10h



	mov ah, 6
	mov al, 0
	mov bh, 0000b     ;color
	mov ch, 22     ;top row of window
	mov cl, 37     ;left most column of window
	mov dh, 22   ;Bottom row of window
	mov dl, 41     ;Right most column of window
	int 10h

	


mov ah, 2
mov dh, 22 ;row
mov dl, 39      ;column
int 10h


mov al,'C'    ;ASCII code of Character 
mov bl,1010b   ;Green color
mov cx,1  
mov ah,09h
int 10h


	mov ah, 6
	mov al, 0
	mov bh, 0000b     ;color
	mov ch, 22     ;top row of window
	mov cl, 43     ;left most column of window
	mov dh, 22   ;Bottom row of window
	mov dl, 47     ;Right most column of window
	int 10h

	


mov ah, 2
mov dh, 22 ;row
mov dl, 45      ;column
int 10h


mov al,'K'    ;ASCII code of Character 
mov bl,1110b   ;Green color
mov cx,1  
mov ah,09h
int 10h




	mov ah, 6
	mov al, 0
	mov bh, 0000b     ;color
	mov ch, 24     ;top row of window
	mov cl, 13     ;left most column of window
	mov dh, 24   ;Bottom row of window
	mov dl, 17     ;Right most column of window
	int 10h

	


mov ah, 2
mov dh, 24 ;row
mov dl, 15      ;column
int 10h


mov al,'B'    ;ASCII code of Character 
mov bl,0100b   ;Green color
mov cx,1  
mov ah,09h
int 10h



	
	mov ah, 6
	mov al, 0
	mov bh, 0000b     ;color
	mov ch, 24     ;top row of window
	mov cl, 19     ;left most column of window
	mov dh, 24   ;Bottom row of window
	mov dl, 23     ;Right most column of window
	int 10h

	


mov ah, 2
mov dh, 24 ;row
mov dl, 21      ;column
int 10h


mov al,'R'    ;ASCII code of Character 
mov bl,1111b   ;Green color
mov cx,1  
mov ah,09h
int 10h


mov ah, 6
	mov al, 0
	mov bh, 0000b     ;color
	mov ch, 24     ;top row of window
	mov cl, 25     ;left most column of window
	mov dh, 24   ;Bottom row of window
	mov dl, 29     ;Right most column of window
	int 10h

	


mov ah, 2
mov dh, 24 ;row
mov dl, 27      ;column
int 10h


mov al,'E'    ;ASCII code of Character 
mov bl,1010b   ;Green color
mov cx,1  
mov ah,09h
int 10h


mov ah, 6
	mov al, 0
	mov bh, 0000b     ;color
	mov ch, 24     ;top row of window
	mov cl, 31     ;left most column of window
	mov dh, 24   ;Bottom row of window
	mov dl, 35     ;Right most column of window
	int 10h

	


mov ah, 2
mov dh, 24 ;row
mov dl, 33      ;column
int 10h


mov al,'A'    ;ASCII code of Character 
mov bl,1110b   ;Green color
mov cx,1  
mov ah,09h
int 10h



mov ah, 6
	mov al, 0
	mov bh, 0000b     ;color
	mov ch, 24     ;top row of window
	mov cl, 37     ;left most column of window
	mov dh, 24   ;Bottom row of window
	mov dl, 41     ;Right most column of window
	int 10h

	


mov ah, 2
mov dh, 24 ;row
mov dl, 39      ;column
int 10h


mov al,'K'    ;ASCII code of Character 
mov bl,0100b   ;Green color
mov cx,1  
mov ah,09h
int 10h



mov ah, 6
	mov al, 0
	mov bh, 0000b     ;color
	mov ch, 24     ;top row of window
	mov cl, 43     ;left most column of window
	mov dh, 24   ;Bottom row of window
	mov dl, 47     ;Right most column of window
	int 10h

	


mov ah, 2
mov dh, 24 ;row
mov dl, 45      ;column
int 10h


mov al,'E'    ;ASCII code of Character 
mov bl,1010b   ;Green color
mov cx,1  
mov ah,09h
int 10h


mov ah, 6
	mov al, 0
	mov bh, 0000b     ;color
	mov ch, 24     ;top row of window
	mov cl, 49     ;left most column of window
	mov dh, 24   ;Bottom row of window
	mov dl, 53     ;Right most column of window
	int 10h

	


mov ah, 2
mov dh, 24 ;row
mov dl, 51      ;column
int 10h


mov al,'R'    ;ASCII code of Character 
mov bl,1111b   ;Green color
mov cx,1  
mov ah,09h
int 10h
inputlop:	
	mov ah,1
int 16h
mov ah,0
int 16h

cmp al,'s'
je funcss

cmp al,08
je exitstop

cmp al,'i'
je instu

cmp al,'h'
je scori

jmp inputlop
	funcss:
	mov func,1
	jmp returi
	
	instu:
	mov func,3
	jmp returi
	
	scori:
	mov func,2
	jmp returi
	
	
	exitstop:
	mov func,4
	returi:
	ret
	starts endp
	
		
specialbrick proc

	mov si,21
	mov cx,numblocks
	mov bx,0
	checking:
		.if bx == 5
		mov cx,1
		push cx
		jmp endloopc
		.endif

		push cx
		
		.if blockVal[si].flag==5
			jmp endloopc
		.endif
		
		.if blockVal[si].special>0
			jmp endloopc
		.endif
		
		push bx
		mov ah, 6
		mov al, 0
		mov bh, 0     ;color
		mov ch, blockVal[si].xup    ;top row of window
		mov cl, blockVal[si].yup     ;left most column of window
		mov dh, blockVal[si].xdown     ;Bottom row of window
		mov dl, blockVal[si].ydown    ;Right most column of window
		mov blockVal[si].flag,5
		int 10h
		inc blockhits
		pop bx
		inc bx
		endloopc:
		add si,7
		pop cx
	loop checking
	mov al,blockhits
	add al,6
	mov blockhits,al
	ret
	
specialbrick endp		


resetgame proc
	mov gameover,0
	mov si,21
	mov cx,numblocks
	loopes:
		mov blockVal[si].flag,0
		add si,7
		loop loopes
	mov funcball,0
	
	mov pad.xup,28
	mov pad.xdown,28
	mov pad.yup,30
	mov pad.ydown,40
	
	mov ball.xup,35
	mov ball.xdown,36
	mov ball.yup,27
	mov ball.ydown,27
	


	mov scorenum,48
	mov seconds,48
	mov seconds1,48
	mov minutess,48
	mov blockhits,0
	mov levelVal,1
	ret

resetgame endp
		
levelup proc


	mov si,21
	mov cx,numblocks
	loopes:
		mov blockVal[si].flag,0
		add si,7
		loop loopes
	mov funcball,0
	
	mov pad.xup,28
	mov pad.xdown,28
	mov pad.yup,30
	mov pad.ydown,40
	
	
	mov ball.xup,35
	mov ball.xdown,36
	mov ball.yup,27
	mov ball.ydown,27
	
	
	
	mov blockhits,0
	inc levelVal
	
	.if levelVal==2
	mov loopcmp,9
		mov al,pad.ydown
		sub al,2
		mov pad.ydown,al
	.endif
	
	.if levelVal==3
	mov loopcmp,7
		mov al,pad.ydown
		sub al,4
		mov pad.ydown,al
	.endif
	
	mov si,21
	mov cx,numblocks
	blockll1:
		push cx
		mov ah, 6
		mov al, 0
		mov bh, blockVal[si].colour     ;color
		mov ch, blockVal[si].xup    ;top row of window
		mov cl, blockVal[si].yup     ;left most column of window
		mov dh, blockVal[si].xdown     ;Bottom row of window
		mov dl, blockVal[si].ydown    ;Right most column of window
		int 10h
		add si,7
		pop cx
		loop blockll1
		ret

levelup endp


		
		
gameMainSceen proc


		call resetgame
		call selectionscreen
		gameloop1:
		screenclear 0
		
		mov si,21
		mov cx,numblocks
		blockml1:
		push cx
		mov ah, 6
		mov al, 0
		cmp blockVal[si].flag,5
		je nomdraw2
		mov bh, blockVal[si].colour     ;color
		mov ch, blockVal[si].xup    ;top row of window
		mov cl, blockVal[si].yup     ;left most column of window
		mov dh, blockVal[si].xdown     ;Bottom row of window
		mov dl, blockVal[si].ydown    ;Right most column of window
		int 10h
		nomdraw2:
		add si,7
		pop cx
		loop blockml1
		
		gameMain:
		
		.if levelVal<3
			.if blockhits==30
			call levelup
			.endif
		.endif
	
	.if levelVal==3
			.if blockhits==30
			mov gamewww,1
			call openfile
			writefile handle,nameVal
			writefile handle,scorenum
			jmp pausemenu
			.endif
		.endif
		
		cmp heartiheart,0
		jne nextis2
		mov gameover,1
		
		nextis2:
		cmp minutess,57
		jne nextis3
		mov gameover,1
		
		
		nextis3:
		
		cmp gameover,1
		je pausemenu
		
		mov ah, 6
		mov al, 0
		mov bh, 0     ;color
		mov ch, 28     ;top row of window
		mov cl, 2     ;left most column of window
		mov dh, 28   ;Bottom row of window
		mov dl, 77   ;Right most column of window
		int 10h
		
		mov ah, 6
		mov al, 0
		mov bh, pad.colour     ;color
		mov ch, pad.xup     ;top row of window
		mov cl, pad.yup     ;left most column of window
		mov dh, pad.xdown   ;Bottom row of window
		mov dl, pad.ydown     ;Right most column of window
		int 10h
		

		cmp ball.xup,2        ;   yup  ;jb checkback
		jbe checkb11 
		cmp ball.xdown,76     ;ydown  ;ja checkback
		jae checkb12        
		cmp ball.yup,5       ; add ch,1 
		jbe checkb21		 ;   xup   je hittrue
		cmp ball.ydown,27	 ;  sub ch,2 je hittrue
		je checkb22			 ;jmp checkback
		cmp ball.ydown,30
		jae notouch
		
		jmp checkback
		
				checkb11:
				mov xsign,-1
				jmp checkback		

				checkb12:
				mov xsign,1
				jmp checkback		
						
				checkb21:
				mov ysign,-1    
				jmp checkback		

				checkb22:
				
				mov al,pad.yup
				mov ah,pad.ydown
				cmp ball.xup,ah
				jbe checkpad1
				jmp checkback
				
				
				
				notouch:
				
				mov al, 0
				mov bh,0
				mov ch, ball.yup
				mov cl, ball.xup 
				mov dh, ball.ydown		
				mov dl, ball.xdown 
				int 10h
				mov funcball,0
				
				dec heartiheart
				mov flaglives,1
				dec locheart
				charcaterMake 3,1,locheart,0000b
				mov locheart,35
				 soundbeep 4560
				
				
				mov ball.xup,34
				mov ball.xdown,35
				mov ball.yup,27
				mov ball.ydown,27
				mov pad.xup,28
				mov pad.xdown,28
				
				.if levelVal==1
				mov pad.yup,30
				mov pad.ydown,40
				.endif
				
				.if levelVal==2
				mov pad.yup,30
				mov pad.ydown,38
				.endif
				
				.if levelVal==3
				mov pad.yup,30
				mov pad.ydown,36
				.endif
				
				mov xfacts,0
				mov yfacts,0
				mov xsign,1
				mov ysign,1
				jmp checkback		
									
									checkpad1:
									dec al
									cmp ball.xdown,al
									jae checkpad2
									jmp checkback
											
										checkpad2:
										mov ysign,1
										mov al,ball.xdown
										mov ah,pad.ydown
										sub ah,al
										
										.if levelVal==1
											.if ah > 5
											mov xsign,1
											.endif
											
											.if ah <= 5
											mov xsign,-1
											.endif
										
										.endif
										.if levelVal==2
											.if ah > 4
											mov xsign,1
											.endif
											.if ah <= 4
											mov xsign,-1
											.endif
										.endif
										.if levelVal==3
											.if ah > 3
											mov xsign,1
											.endif
											.if ah <= 3
											mov xsign,-1
											.endif
										.endif
										jmp checkback
								
												
		
		checkback:

		cmp funcball,1
		je ballfuncs
		
		call ballmaking 
		mov xfacts,0
		mov yfacts,0
			
		jmp movwali
		
		ballfuncs:
		mov ax,loopcmp
		cmp ax,loopcounter
		jne movwali
			call ballmaking
			

		
		movwali:
		
		cmp funcball,1
		je mowalireturn
		
		mowalireturn:
		mov ax,0
		mov bx,0
		mov cx,1
		mov dx,0
		mov si,0
		mov dl,5


		scr1:
		
			mov ah, 2
			mov dh, 1 ;row
			int 10h

			mov al,scorestr[si]    ;ASCII code of Character 
			cmp al,'$'
			je scr1end
			mov bl,12   
			mov ah,09h
			int 10h
			inc si
			inc dl
			jmp scr1
		
		scr1end:
		mov ax,0
		mov bx,0
		mov ah,0
		mov al,scorenum
		
		sub al,48
		
		mov bl,10
		
		div bl
		
		add al,48
		add ah,48
		mov tempscores,ah

		charcaterMake al,1,11,12
		charcaterMake tempscores,1,12,12
	
			push ax
		push bx
		push cx
		push dx
		
		push heartiheart
		cmp looptimer,45
		jne nextis
		
		mov ax,0
		mov bx,0
		mov ah,0
		mov al,seconds
		
		sub al,48
		
		mov bl,10
		
		div bl
		
		add al,48
		add ah,48
		mov seconds1,ah
		cmp al,54
		jne characteruwu
		mov seconds,48
		mov seconds1,48
		mov al,48
		mov ah,48
		inc minutess
		characteruwu:
		charcaterMake al,3,28,1110b
		charcaterMake seconds1,3,29,1110b
		charcaterMake minutess,3,24,1110b
		charcaterMake ':',3,26,1110b

		
		inc seconds
		mov looptimer,0
		
		nextis:
		cmp flaglives,1
		jne endsloopsi
		mov flaglives,0
	
		loopheart:
		cmp heartiheart,0
		je endsloopsi
		charcaterMake 3,1,locheart,10
		dec heartiheart
		inc locheart
		jmp loopheart
		
		endsloopsi:
		

		
		pop heartiheart	
		pop dx
		pop cx
		pop bx
		pop ax
		
			
			
	
		


		mov si,0
		add dl,5

		time1:
		
			mov ah, 2
			mov dh, 3 ;row
			int 10h

			mov al,timestr[si]    ;ASCII code of Character 
			cmp al,'$'
			je time1end
			mov bl,14   
			mov ah,09h
			int 10h
			inc si
			inc dl
			jmp time1
		
		time1end:

		mov si,0
		add dl,5

		live1:
		
			mov ah, 2
			mov dh, 1 ;row
			int 10h

			mov al,livestr[si]    ;ASCII code of Character 
			cmp al,'$'
			je live1end
			mov bl,10   
			mov ah,09h
			int 10h
			inc si
			inc dl
			jmp live1
		
		live1end:
		
		
		

		
		mov si,0
		add dl,5
		nam1:
		
			mov ah, 2
			mov dh, 3 ;row
			int 10h

			mov al,Namestr[si]    ;ASCII code of Character 
			cmp al,'$'
			je nam1end
			mov bl,9   
			mov ah,09h
			int 10h
			inc si
			inc dl
			jmp nam1
		
		nam1end:

		mov ax,0
		mov bx,0
		mov cx,1
		mov si,0
		nam2:
		
			mov ah, 2
			mov dh, 3 ;row
			int 10h

			mov al,nameVal[si]    ;ASCII code of Character 
			cmp al,'$'
			je nam2end
			mov bl,9   
			mov ah,09h
			int 10h
			inc si
			inc dl
			jmp nam2
		
		nam2end:


		mov si,0
		add dl,5
		lvl:
		
			mov ah, 2
			mov dh, 1 ;row
			int 10h

			mov al,levelstr[si]    ;ASCII code of Character 
			cmp al,'$'
			je lvlend
			mov bl,5   
			mov ah,09h
			int 10h
			inc si
			inc dl
			jmp lvl
		
		lvlend:


		mov ah, 2
		mov dh, 1 ;row
		int 10h

		mov al,levelVal		;ASCII code of Character 
		add al,48
		mov bl,5   
		mov ah,09h
		int 10h
		

		mov cx,3
		mov si,0
		
		
		gamel1:
		push cx
		mov ah, 6
		mov al, 0
		mov bh, blockVal[si].colour     ;color
		mov ch, blockVal[si].xup    ;top row of window
		mov cl, blockVal[si].yup     ;left most column of window
		mov dh, blockVal[si].xdown     ;Bottom row of window
		mov dl, blockVal[si].ydown    ;Right most column of window
		int 10h
		add si,7
		pop cx
		loop gamel1
		
		
		mov cx,numblocks
		blockl1:
		push cx
		mov ah, 6
		mov al, 0
		cmp blockVal[si].flag,5
		je checkblockback
		mov bh, blockVal[si].colour     ;color
		mov ch, blockVal[si].xup    ;top row of window
		mov cl, blockVal[si].yup     ;left most column of window
		mov dh, blockVal[si].xdown     ;Bottom row of window
		mov dl, blockVal[si].ydown    ;Right most column of window
		jmp checkblock
		checkblockback:
		add si,7
		pop cx
		loop blockl1
		
		jmp aagechalo
		
		checkblock:
		
		sub cl,2
		inc dl
		inc dl
		cmp ball.xup,cl 
		jb checkblockback                     ;   yup  ;jb checkback
		cmp ball.xdown,dl     ;ydown  ;ja checkback
		ja checkblockback        
		
		cmp ysign,-1
		je hitup
		add dh,1
		cmp ball.ydown,dh
		jne checkblockback
		
		.if levelVal==1 
		mov blockVal[si].flag,5
		mov ysign,-1
		mov bh,0
		int 10h
		inc blockhits
		inc scorenum
		.endif
			
		.if levelVal == 2
			.if blockVal[si].flag < 1
			inc blockVal[si].flag
			mov ysign,-1
			mov ch, blockVal[si].xup    ;top row of window
			mov cl, blockVal[si].yup     ;left most column of window
			mov dh, blockVal[si].xdown     ;Bottom row of window
			mov dl, blockVal[si].ydown    ;Right most column of window
			mov bh,11
			int 10h
			jmp checkblockback
			.endif
			
		mov blockVal[si].flag,5
		mov ch, blockVal[si].xup    ;top row of window
		mov cl, blockVal[si].yup     ;left most column of window
		mov dh, blockVal[si].xdown     ;Bottom row of window
		mov dl, blockVal[si].ydown    ;Right most column of window
		mov ysign,-1
		mov bh,0
		int 10h
		inc blockhits
		inc scorenum
		.endif
		
		.if levelVal == 3
		
		
			.if blockVal[si].special==1
			mov ysign,-1
			jmp checkblockback
			.endif

			.if blockVal[si].special==2
			mov ysign,-1
			mov blockVal[si].flag,5
			mov ch, blockVal[si].xup    ;top row of window
			mov cl, blockVal[si].yup     ;left most column of window
			mov dh, blockVal[si].xdown     ;Bottom row of window
			mov dl, blockVal[si].ydown    ;Right most column of window
			mov bh,0
			int 10h
			inc blockhits
			call specialbrick
			jmp checkblockback

			.endif
			
			
			.if blockVal[si].flag < 2
			inc blockVal[si].flag
			mov ysign,-1
			mov ch, blockVal[si].xup    ;top row of window
			mov cl, blockVal[si].yup     ;left most column of window
			mov dh, blockVal[si].xdown     ;Bottom row of window
			mov dl, blockVal[si].ydown    ;Right most column of window
			mov bh,11
			int 10h
			jmp checkblockback
			.endif
			
		mov blockVal[si].flag,5
		mov ch, blockVal[si].xup    ;top row of window
		mov cl, blockVal[si].yup     ;left most column of window
		mov dh, blockVal[si].xdown     ;Bottom row of window
		mov dl, blockVal[si].ydown    ;Right most column of window
		mov ysign,-1
		mov bh,0
		int 10h
		inc blockhits
		inc scorenum
		.endif
		
		jmp checkblockback
				
		hitup:
			sub ch,1
			cmp ball.yup,ch
			jne checkblockback
		
		.if levelVal==1 
		mov blockVal[si].flag,5
		mov ysign,1
		mov bh,0
		int 10h
		inc blockhits
		inc scorenum
		.endif
			
		.if levelVal == 2
			.if blockVal[si].flag < 1
			inc blockVal[si].flag
			mov ysign,1
			mov ch, blockVal[si].xup    ;top row of window
			mov cl, blockVal[si].yup     ;left most column of window
			mov dh, blockVal[si].xdown     ;Bottom row of window
			mov dl, blockVal[si].ydown    ;Right most column of window
			mov bh,11
			int 10h
			jmp checkblockback
			.endif
			
		mov blockVal[si].flag,5
		mov ch, blockVal[si].xup    ;top row of window
		mov cl, blockVal[si].yup     ;left most column of window
		mov dh, blockVal[si].xdown     ;Bottom row of window
		mov dl, blockVal[si].ydown    ;Right most column of window
		mov ysign,1
		mov bh,0
		int 10h
		inc blockhits
		inc scorenum
		.endif
		
		.if levelVal == 3
			
			.if blockVal[si].special==1
			mov ysign,1
			jmp checkblockback
			.endif
			
			.if blockVal[si].special==2
			mov ysign,1
			mov blockVal[si].flag,5
			mov ch, blockVal[si].xup    ;top row of window
			mov cl, blockVal[si].yup     ;left most column of window
			mov dh, blockVal[si].xdown     ;Bottom row of window
			mov dl, blockVal[si].ydown    ;Right most column of window
			mov bh,0
			int 10h
			inc blockhits
			call specialbrick
			jmp checkblockback
			.endif
			
			
			.if blockVal[si].flag < 2
			inc blockVal[si].flag
			mov ysign,1
			mov ch, blockVal[si].xup    ;top row of window
			mov cl, blockVal[si].yup     ;left most column of window
			mov dh, blockVal[si].xdown     ;Bottom row of window
			mov dl, blockVal[si].ydown    ;Right most column of window
			mov bh,11
			int 10h
			jmp checkblockback
			.endif
			
		mov blockVal[si].flag,5
		mov ch, blockVal[si].xup    ;top row of window
		mov cl, blockVal[si].yup     ;left most column of window
		mov dh, blockVal[si].xdown     ;Bottom row of window
		mov dl, blockVal[si].ydown    ;Right most column of window
		mov ysign,1
		mov bh,0
		int 10h
		inc blockhits
		inc scorenum
		
		.endif
		jmp checkblockback
		
		
		
		aagechalo:
		cmp funcball,1
		jne nexts
		spcdeflection:

		mov ax,loopdef
		cmp ax,loopcounter
		jne nexts			
			
		nexts:
		mov ah,1
		int 16h
		jz exitts
		mov ah,0
		int 16h
		
		cmp ah,4bh
		je lefts

		cmp ah,4dh
		je rights

		cmp al,08
		je pausemenu
		
		cmp ah,57
		je ballflg
	
		
		
		jmp exitts
		
		
		ballflg:
			mov funcball,1
			mov yfacts,1
			mov xfacts,1
			jmp exitts
		
		
		
		
		lefts:
			
			cmp pad.yup,2
			je exitts
			sub pad.yup,1
			sub pad.ydown,1
			
	
				
			cmp funcball,1
			je exitts
			mov xfacts,1
			mov yfacts,0
		
			
			jmp exitts

		rights:
			cmp pad.ydown,77
			je exitts
			add pad.yup,1
			add pad.ydown,1
			cmp funcball,1
			je exitts
			mov xfacts,-1
			mov yfacts,0
			
		
		exitts:
		add loopcounter,1

		mov ax,loopcmp
		add ax,1
		cmp ax,loopcounter
		jne resets
		mov loopcounter,0
		
		resets:
		inc looptimer
		jmp gameMain



pausemenu:

	.if gameover==1
	call losepage
		jmp exitgmain
	.endif
	.if gamewww==1
	call winspage
		jmp exitgmain
	.endif

	mov ah, 0
	mov al, 12h    
	int 10h

	mov ah, 6
	mov al, 0
	mov bh, 1111b     ;color
	mov ch, 20    ;top row of window
	mov cl, 0    ;left most column of window
	mov dh, 40     ;Bottom row of window
	mov dl,80    ;Right most column of window
	int 10h

	add si,4

	mov ah, 6
	mov al, 0
	mov bh, 12     ;color
	mov ch, 0     ;top row of window
	mov cl, 0     ;left most column of window
	mov dh, 30   ;Bottom row of window
	mov dl, 1     ;Right most column of window
	int 10h

	
	mov ah, 6
	mov al, 0
	mov bh, 12     ;color
	mov ch, 0     ;top row of window
	mov cl, 78     ;left most column of window
	mov dh, 30   ;Bottom row of window
	mov dl, 79     ;Right most column of window
	int 10h



	mov ah, 6
	mov al, 0
	mov bh, 12     ;color
	mov ch, 0     ;top row of window
	mov cl, 0     ;left most column of window
	mov dh, 0   ;Bottom row of window
	mov dl, 100    ;Right most column of window
	int 10h



	mov ah, 6
	mov al, 0
	mov bh, 12     ;color
	mov ch, 29   ;top row of window
	mov cl, 1     ;left most column of window
	mov dh, 29   ;Bottom row of window
	mov dl, 77    ;Right most column of window
	int 10h
	
	
	mov bx,50
	mov si,100

	pl1:
	MOV CX, bx    
	MOV DX, 92    
	MOV AL, 12  
	MOV AH, 0CH 
	INT 10H
	mov cx,si
	dec si
	inc bx
	loop pl1

	mov bx,92
	mov si,20

	pl2:
	MOV CX, 50    
	MOV DX, bx    
	MOV AL, 12  
	MOV AH, 0CH 
	INT 10H
	mov cx,si
	dec si
	inc bx
	loop pl2


	mov bx,50
	mov si,100

	pl3:
	MOV CX, bx    
	MOV DX, 112    
	MOV AL, 12  
	MOV AH, 0CH 
	INT 10H
	mov cx,si
	dec si
	inc bx
	loop pl3



	mov bx,92
	mov si,20

	pl4:
	MOV CX, 150    
	MOV DX, bx    
	MOV AL, 12  
	MOV AH, 0CH 
	INT 10H
	mov cx,si
	dec si
	inc bx
	loop pl4



	mov ah, 2
	mov dh, 6 ;row
	mov dl, 10     ;column
	int 10h

	mov al,'R'    ;ASCII code of Character 
	mov bx,0
	mov bl,1111b   ;Green color
	mov cx,1  
	mov ah,09h
	int 10h

	mov ah, 2
	mov dh, 6 ;row
	mov dl, 11      ;column
	int 10h

	mov al,'E'    ;ASCII code of Character 
	mov bx,0
	mov bl,0100b   ;Green color
	mov cx,1  
	mov ah,09h
	int 10h


	mov ah, 2
	mov dh, 6 ;row
	mov dl, 12      ;column
	int 10h

	mov al,'S'    ;ASCII code of Character 
	mov bx,0
	mov bl,1010b   ;Green color
	mov cx,1  
	mov ah,09h
	int 10h



	mov ah, 2
	mov dh, 6 ;row
	mov dl, 13      ;column
	int 10h

	mov al,'U'    ;ASCII code of Character 
	mov bx,0
	mov bl,0100b   ;Green color
	mov cx,1  
	mov ah,09h
	int 10h

		

	mov ah, 2
	mov dh, 6 ;row
	mov dl, 14     ;column
	int 10h

	mov al,'M'    ;ASCII code of Character 
	mov bx,0
	mov bl,1111b   ;Green color
	mov cx,1  
	mov ah,09h
	int 10h

	mov ah, 2
	mov dh, 6 ;row
	mov dl, 15     ;column
	int 10h

	mov al,'E'    ;ASCII code of Character 
	mov bx,0
	mov bl,1111b   ;Green color
	mov cx,1  
	mov ah,09h
	int 10h


	mov bx,50
	mov si,100

	pl11:
	MOV CX, bx    
	MOV DX, 140    
	MOV AL, 12  
	MOV AH, 0CH 
	INT 10H
	mov cx,si
	dec si
	inc bx
	loop pl11

	mov bx,140
	mov si,20

	pl22:
	MOV CX, 50    
	MOV DX, bx    
	MOV AL, 12  
	MOV AH, 0CH 
	INT 10H
	mov cx,si
	dec si
	inc bx
	loop pl22


	mov bx,50
	mov si,100

	pl33:
	MOV CX, bx    
	MOV DX, 160    
	MOV AL, 12  
	MOV AH, 0CH 
	INT 10H
	mov cx,si
	dec si
	inc bx
	loop pl33



	mov bx,140
	mov si,20

	pl44:
	MOV CX, 150    
	MOV DX, bx    
	MOV AL, 12  
	MOV AH, 0CH 
	INT 10H
	mov cx,si
	dec si
	inc bx
	loop pl44



	mov ah, 2
	mov dh, 9 ;row
	mov dl, 8     ;column
	int 10h

	mov al,'M'    ;ASCII code of Character 
	mov bx,0
	mov bl,0100b   ;Green color
	mov cx,1  
	mov ah,09h
	int 10h

	mov ah, 2
	mov dh, 9 ;row
	mov dl, 9      ;column
	int 10h

	mov al,'A'    ;ASCII code of Character 
	mov bx,0
	mov bl,1111b   ;Green color
	mov cx,1  
	mov ah,09h
	int 10h


	mov ah, 2
	mov dh, 9 ;row
	mov dl, 10      ;column
	int 10h

	mov al,'I'    ;ASCII code of Character 
	mov bx,0
	mov bl,1010b   ;Green color
	mov cx,1  
	mov ah,09h
	int 10h



	mov ah, 2
	mov dh, 9 ;row
	mov dl, 11      ;column
	int 10h

	mov al,'N'    ;ASCII code of Character 
	mov bx,0
	mov bl,0100b   ;Green color
	mov cx,1  
	mov ah,09h
	int 10h



	mov ah, 2
	mov dh, 9 ;row
	mov dl, 12     ;column
	int 10h

	mov al,' '    ;ASCII code of Character 
	mov bx,0
	mov bl,1111b   ;Green color
	mov cx,1  
	mov ah,09h
	int 10h


	mov ah, 2
	mov dh, 9 ;row
	mov dl, 13     ;column
	int 10h

	mov al,'M'    ;ASCII code of Character 
	mov bx,0
	mov bl,1010b   ;Green color
	mov cx,1  
	mov ah,09h
	int 10h


	mov ah, 2
	mov dh, 9 ;row
	mov dl, 14     ;column
	int 10h

	mov al,'E'    ;ASCII code of Character 
	mov bx,0
	mov bl,0100b   ;Green color
	mov cx,1  
	mov ah,09h
	int 10h


	mov ah, 2
	mov dh, 9 ;row
	mov dl, 15     ;column
	int 10h

	mov al,'N'    ;ASCII code of Character 
	mov bx,0
	mov bl,1111b   ;Green color
	mov cx,1  
	mov ah,09h
	int 10h


	mov ah, 2
	mov dh, 9 ;row
	mov dl, 16     ;column
	int 10h

	mov al,'U'    ;ASCII code of Character 
	mov bx,0
	mov bl,1010b   ;Green color
	mov cx,1  
	mov ah,09h
	int 10h



		
		mov ah, 6
		mov al, 0
		mov bh, 1110b     ;color
		mov ch, 13    ;top row of window
		mov cl, 45     ;left most column of window
		mov dh, 14   ;Bottom row of window
		mov dl, 70     ;Right most column of window
		int 10h
		
		mov ah, 6
		mov al, 0
		mov bh, 0100b     ;color
		mov ch, 6     ;top row of window
		mov cl, 45     ;left most column of window
		mov dh, 12   ;Bottom row of window
		mov dl, 70     ;Right most column of window
		int 10h
		
		
		mov ah, 6
		mov al, 0
		mov bh, 0000b     ;color
		mov ch, 7     ;top row of window
		mov cl, 50     ;left most column of window
		mov dh, 8   ;Bottom row of window
		mov dl, 51     ;Right most column of window
		int 10h
		
		mov ah, 6
		mov al, 0
		mov bh, 0000b     ;color
		mov ch, 7     ;top row of window
		mov cl, 54     ;left most column of window
		mov dh, 8   ;Bottom row of window
		mov dl, 55     ;Right most column of window
		int 10h
		
		mov ah, 6
		mov al, 0
		mov bh, 0000b     ;color
		mov ch, 7     ;top row of window
		mov cl, 54     ;left most column of window
		mov dh, 7   ;Bottom row of window
		mov dl, 59     ;Right most column of window
		int 10h
		
		mov ah, 6
		mov al, 0
		mov bh, 0000b     ;color
		mov ch, 9     ;top row of window
		mov cl, 50     ;left most column of window
		mov dh, 9   ;Bottom row of window
		mov dl, 58     ;Right most column of window
		int 10h


		
		mov ah, 6
		mov al, 0
		mov bh, 0000b     ;color
		mov ch, 10     ;top row of window
		mov cl, 54     ;left most column of window
		mov dh, 11   ;Bottom row of window
		mov dl, 55     ;Right most column of window
		int 10h
		
		
		mov ah, 6
		mov al, 0
		mov bh, 0000b     ;color
		mov ch, 9     ;top row of window
		mov cl, 58     ;left most column of window
		mov dh, 11   ;Bottom row of window
		mov dl, 59     ;Right most column of window
		int 10h
		
		
		mov ah, 6
		mov al, 0
		mov bh, 0000b     ;color
		mov ch, 11     ;top row of window
		mov cl, 50     ;left most column of window
		mov dh, 11   ;Bottom row of window
		mov dl, 53     ;Right most column of window
		int 10h

		


		
		mov ah, 6
		mov al, 0
		mov bh, 0000b     ;color
		mov ch, 22     ;top row of window
		mov cl, 19     ;left most column of window
		mov dh, 22   ;Bottom row of window
		mov dl, 23     ;Right most column of window
		int 10h

		


	mov ah, 2
	mov dh, 22 ;row
	mov dl, 21      ;column
	int 10h


	mov al,'B'    ;ASCII code of Character 
	mov bl,1010b   ;Green color
	mov cx,1  
	mov ah,09h
	int 10h



		mov ah, 6
		mov al, 0
		mov bh, 0000b     ;color
		mov ch, 22     ;top row of window
		mov cl, 25     ;left most column of window
		mov dh, 22   ;Bottom row of window
		mov dl, 29     ;Right most column of window
		int 10h

		


	mov ah, 2
	mov dh, 22 ;row
	mov dl, 27      ;column
	int 10h


	mov al,'R'    ;ASCII code of Character 
	mov bl,1111b   ;Green color
	mov cx,1  
	mov ah,09h
	int 10h





		mov ah, 6
		mov al, 0
		mov bh, 0000b     ;color
		mov ch, 22     ;top row of window
		mov cl, 31     ;left most column of window
		mov dh, 22   ;Bottom row of window
		mov dl, 35     ;Right most column of window
		int 10h

		


	mov ah, 2
	mov dh, 22 ;row
	mov dl, 33      ;column
	int 10h


	mov al,'I'    ;ASCII code of Character 
	mov bl,0100b   ;Green color
	mov cx,1  
	mov ah,09h
	int 10h



		mov ah, 6
		mov al, 0
		mov bh, 0000b     ;color
		mov ch, 22     ;top row of window
		mov cl, 37     ;left most column of window
		mov dh, 22   ;Bottom row of window
		mov dl, 41     ;Right most column of window
		int 10h

		


	mov ah, 2
	mov dh, 22 ;row
	mov dl, 39      ;column
	int 10h


	mov al,'C'    ;ASCII code of Character 
	mov bl,1010b   ;Green color
	mov cx,1  
	mov ah,09h
	int 10h


		mov ah, 6
		mov al, 0
		mov bh, 0000b     ;color
		mov ch, 22     ;top row of window
		mov cl, 43     ;left most column of window
		mov dh, 22   ;Bottom row of window
		mov dl, 47     ;Right most column of window
		int 10h

		


	mov ah, 2
	mov dh, 22 ;row
	mov dl, 45      ;column
	int 10h


	mov al,'K'    ;ASCII code of Character 
	mov bl,1110b   ;Green color
	mov cx,1  
	mov ah,09h
	int 10h




		mov ah, 6
		mov al, 0
		mov bh, 0000b     ;color
		mov ch, 24     ;top row of window
		mov cl, 13     ;left most column of window
		mov dh, 24   ;Bottom row of window
		mov dl, 17     ;Right most column of window
		int 10h

		


	mov ah, 2
	mov dh, 24 ;row
	mov dl, 15      ;column
	int 10h


	mov al,'B'    ;ASCII code of Character 
	mov bl,0100b   ;Green color
	mov cx,1  
	mov ah,09h
	int 10h



		
		mov ah, 6
		mov al, 0
		mov bh, 0000b     ;color
		mov ch, 24     ;top row of window
		mov cl, 19     ;left most column of window
		mov dh, 24   ;Bottom row of window
		mov dl, 23     ;Right most column of window
		int 10h

		


	mov ah, 2
	mov dh, 24 ;row
	mov dl, 21      ;column
	int 10h


	mov al,'R'    ;ASCII code of Character 
	mov bl,1111b   ;Green color
	mov cx,1  
	mov ah,09h
	int 10h


	mov ah, 6
		mov al, 0
		mov bh, 0000b     ;color
		mov ch, 24     ;top row of window
		mov cl, 25     ;left most column of window
		mov dh, 24   ;Bottom row of window
		mov dl, 29     ;Right most column of window
		int 10h

		


	mov ah, 2
	mov dh, 24 ;row
	mov dl, 27      ;column
	int 10h


	mov al,'E'    ;ASCII code of Character 
	mov bl,1010b   ;Green color
	mov cx,1  
	mov ah,09h
	int 10h


	mov ah, 6
		mov al, 0
		mov bh, 0000b     ;color
		mov ch, 24     ;top row of window
		mov cl, 31     ;left most column of window
		mov dh, 24   ;Bottom row of window
		mov dl, 35     ;Right most column of window
		int 10h

		


	mov ah, 2
	mov dh, 24 ;row
	mov dl, 33      ;column
	int 10h


	mov al,'A'    ;ASCII code of Character 
	mov bl,1110b   ;Green color
	mov cx,1  
	mov ah,09h
	int 10h



	mov ah, 6
		mov al, 0
		mov bh, 0000b     ;color
		mov ch, 24     ;top row of window
		mov cl, 37     ;left most column of window
		mov dh, 24   ;Bottom row of window
		mov dl, 41     ;Right most column of window
		int 10h

		


	mov ah, 2
	mov dh, 24 ;row
	mov dl, 39      ;column
	int 10h


	mov al,'K'    ;ASCII code of Character 
	mov bl,0100b   ;Green color
	mov cx,1  
	mov ah,09h
	int 10h



	mov ah, 6
		mov al, 0
		mov bh, 0000b     ;color
		mov ch, 24     ;top row of window
		mov cl, 43     ;left most column of window
		mov dh, 24   ;Bottom row of window
		mov dl, 47     ;Right most column of window
		int 10h

		


	mov ah, 2
	mov dh, 24 ;row
	mov dl, 45      ;column
	int 10h


	mov al,'E'    ;ASCII code of Character 
	mov bl,1010b   ;Green color
	mov cx,1  
	mov ah,09h
	int 10h


	mov ah, 6
		mov al, 0
		mov bh, 0000b     ;color
		mov ch, 24     ;top row of window
		mov cl, 49     ;left most column of window
		mov dh, 24   ;Bottom row of window
		mov dl, 53     ;Right most column of window
		int 10h

		


	mov ah, 2
	mov dh, 24 ;row
	mov dl, 51      ;column
	int 10h


	mov al,'R'    ;ASCII code of Character 
	mov bl,1111b   ;Green color
	mov cx,1  
	mov ah,09h
	int 10h

		inputlop:	
		mov ah,1
		int 16h
		mov ah,0
		int 16h

		cmp al,'r'
		je gameloop1
		cmp al,'R'
		je gameloop1

		cmp al,'M'
		je exitgmain
		cmp al,'m'
		je exitgmain
		cmp al,8
		je exitgmain

	jmp inputlop
	
	exitgmain:

	ret
	
gameMainSceen endp

main proc



	
	mov ax,@data
	mov ds,ax
	mov ax,0
	
	;call createfile for first run
	call insernamepage
	
	back:
	call starts
	
	cmp func,3
	
	je instu1
	
	cmp func,1
	
	je game1

	cmp func,4
	
	je exitit
	

	
game1:
call gameMainSceen
jmp back

instu1:
call instuctionpage
jmp back


	exitit:
	
	
mov ah, 4ch
int 21h
main endp
end