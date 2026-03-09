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


movb	$1 , counter

jmp sprawdz_warunek
petla_for:




mov	counter , %al		# wczytaj licznik do dowolnego, 8-bitowego rejestru
add	$48 , %al		# przesuniecie +48, wg tablicy ASCII
mov	%al , new_line - 1	# zapisz kod znaku pod odpowiedni adres

mov	$sys_write , %eax
mov	$stdout , %edi
mov	$str , %esi
mov	$strlen , %edx
syscall

incb	counter		# counter++

sprawdz_warunek:
cmpb 	$10,counter
jbe	petla_for 	# jump if below or equal (poki counter <=10)
#jna 	petla_for

koniec_for:


mov	$sys_exit , %eax
xor	%edi , %edi		# kod bledu:  %edi = %edi xor %edi = 0
syscall

