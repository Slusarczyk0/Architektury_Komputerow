.globl _start
.equ	sys_write,	1
.equ	sys_exit,	60
.equ	stdout,		1
.equ	strlen, 	new_line + 1 - str

.data

counter:	.byte	40
str:		.ascii	"iteracja nr: x"
new_line:	.byte	0x0A


.text

_start:

movb	$10 , counter


petla_for:
mov	counter , %al		# wczytaj licznik do dowolnego, 8-bitowego rejestru
add	$48 , %al		# przesuniecie +48, wg tablicy ASCII
mov	%al , new_line - 1	# zapisz kod znaku pod odpowiedni adres
mov	$sys_write , %eax
mov	$stdout , %edi
mov	$str , %esi
mov	$strlen , %edx
syscall

decb	counter		# dec ustawia flage Z (zero)
jnz	petla_for	# jump not zero

koniec_for:
mov	$sys_exit , %eax
xor	%edi , %edi		# kod bledu:  %edi = %edi xor %edi = 0
syscall

