.section .note.GNU-stack, "", @progbits

.globl	main

.data

str_tf:		.string "tfloat = %3.20Lf\n"
str_d:		.string "double = %3.20lf\n"
str_f:		.string "float = %3.20f\n"

cw:	.word 0

f_tf:	.tfloat	0.0
f_d:	.double	0.0
f_f:	.float		0.0
f_2:	.float		2.0
f_nan:	.long 0x7f800001	# NaN
f_inf:	.long 0x7f800000	# +inf

.text

main:
sub	$8 , %rsp

finit

# 1) Ustaw odpowiednia precyzje obliczen oraz sposob zaokraglania.
# 2) Wlacz ("odmaskuj") sygnalizwoanie wyjatkow.

fstcw	cw
andw	$0xF0E4 , cw
orw	$0x0300 , cw
fldcw	cw

# 1) Wykonaj dzialanie sqrt(2.0) * sqrt(2.0) - 2.0
# 2) Wymus zgloszenie (wybranego) wyjatku

flds	f_2		# st(0) = 2
fldz
fdivrp			#zaladowanie i  dzielenie przez 0 zeby byl blad st(1)/st(0) = 2/0
#fchs			# zmiana znaku z 2 na -2 zeby byl blad
fsqrt			# st(0) = sqrt(st(0))
fmul	%st(0) 		# st(0) = st(0) * st(0)
fsubs	f_2		#st(0) = st(0) - 2 = sqrt(2)*sqrt(2) - 2


# Wydrukuj wynik z rejestru %st(0)

call	print_tfloat

xor	%eax , %eax
add	$8 , %rsp
ret

#####################################################

print_tfloat:
sub	$24 , %rsp
fstpt	(%rsp)
mov	$str_tf , %rdi
xor	%eax , %eax
call	printf
add	$24 , %rsp
ret

#####################################################

print_double:
sub	$8 , %rsp
fstl	f_d
movsd	f_d , %xmm0
mov	$str_d , %rdi
mov	$1 , %eax
call	printf
add	$8 , %rsp
ret

#####################################################

print_float:
sub	$8 , %rsp
fsts	f_f
movss	f_f , %xmm0
cvtss2sd %xmm0 , %xmm0
mov	$str_f , %rdi
mov	$1 , %eax
call	printf
add	$8 , %rsp
ret

#####################################################

