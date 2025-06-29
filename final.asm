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
@aux4                dd		 ?                             
@aux5                dd		 ?                             
_0                   dd		 0                             
_8                   dd		 8                             
_2                   dd		 2                             
@aux6                dd		 ?                             
@aux7                dd		 ?                             
@aux8                dd		 ?                             
@aux9                dd		 ?                             
_1.900000            dd		 1.900000                      
@aux10               dd		 ?                             

.CODE
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
FSTP a

FLD a
FLD _3
FMUL
FSTP @aux4

FLD b
FLD a
FSUB
FSTP @aux5

FLD @aux4
FLD @aux5
FXCH
FCOM
FSTSW AX
SAHF
JA etiq_true23 

FLD c
FLD _0
FXCH
FCOM
FSTSW AX
SAHF
JE etiq_else39 

etiq_true23:
FLD _8
FLD _2
FADD
FSTP @aux6

FLD _1
FLD _7
FSUB
FSTP @aux7

FLD _3
FLD @aux7
FDIV
FSTP @aux8

FLD @aux6
FLD @aux8
FMUL
FSTP @aux9

FLD @aux9
FLD _1.900000
FADD
FSTP @aux10

FLD @aux10
FSTP c
JMP etiq_endif43 

etiq_else39:
FLD _0
FSTP c

etiq_endif43:
FFREE
mov ax,4c00h
int 21h
End