include macros2.asm
include number.asm
.MODEL LARGE
.STACK 200h
.386
.DATA

a1                   dd		 ?                             
b1                   dd		 ?                             
variable1            dd		 ?                             
a                    dd		 ?                             
b                    dd		 ?                             
c                    dd		 ?                             
p1                   db		 ?                             , '$', 14 dup (?)
p2                   db		 ?                             , '$', 14 dup (?)
p3                   db		 ?                             , '$', 14 dup (?)
d                    db		 ?                             , '$', 14 dup (?)
variable2            dd		 ?                             
a2                   dd		 ?                             
b3                   dd		 ?                             
_3                   dd		 3                             
_1                   dd		 1                             
_7                   dd		 7                             
@aux1                dd		 ?                             
@aux2                dd		 ?                             
@aux3                dd		 ?                             
_1_200000            dd		 1.200000                      
@aux4                dd		 ?                             
_Hola__mundo____!!   db		 "Hola  mundo    !!"           , '$', 14 dup (?)
_msgPRESIONE            db  0DH,0AH,"Presione una tecla para continuar...",'$'
_NEWLINE            db  0DH,0AH,'$'

.CODE
.START:
MOV EAX,@DATA
MOV DS,EAX
MOV ES,EAX;


FLD _1
FLD _7
FSUB
FSTP @aux1

FLD _3
FLD @aux1
FDIV
FSTP @aux2

FLD a
FLD @aux2
FMUL
FSTP @aux3

FLD @aux3
FLD _1.200000
FMUL
FSTP @aux4

FLD @aux4
FSTP a

FLD _"Hola  mundo    !!"
FSTP d

mov dx,OFFSET _NEWLINE
mov ah,9
int 21h
mov dx,OFFSET _msgPRESIONE
mov ah,9
int 21h
mov ah, 1
int 21h
FFREE
mov ax,4c00h
int 21h
END START