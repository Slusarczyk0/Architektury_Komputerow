.section .note.GNU-stack, "", @progbits

# Program ma obliczyc sume N poczatkowych wyrazow szeregu:
# S10 = (1/1) + (1/10) + (1/100) + (1/1000) + ...
# Jednostka obliczeniowa dowolna - x87 lub SSE.
# Obliczenia oraz wydrukowanie wyniku - liczby pojedynczej precyzji.

.globl	main

.equ	N , 10

.data

outstr:	.string	"S10 = %1.10f\n"
c10:	.float	10.0
res:	.float	0.0
cw:	.word	0

.text

main:
sub	$8 , %rsp

# W zaleznosci od wybranej jenostki arytmetycznej:
# - wlacz FPU,
# - ustaw pojedyncza precyzje obliczen,
# - zaokraglanie "to nearest even".

# ...
#push %rbp
mov $N, %ecx

finit
fstcw cw
andw $0xf0ff, cw
orw $0x0000, cw
fldcw cw


mov $N, %ecx
fld1 #st(0) = 1
fldz #st(0) = 0, st(1) = 1


# Zainicjuj rejestry odpowiednimi wartosciami poczatkowymi,
# oblicz N pierwszych wyrazow szeregu.

# ...

for:

fadd %st(1), %st(0) 
#fldl c10
fxch %st(1) 
fdivs c10
fxch %st(1) 


dec %ecx
jnz	for

fstps res
movss res, %xmm0
cvtss2sd	%xmm0, %xmm0
mov $outstr, %rdi
mov $1, %eax
call	printf
add $8, %rsp
ret
