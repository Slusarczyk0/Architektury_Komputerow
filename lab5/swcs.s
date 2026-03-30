#################################################################
#
# Laboratorium 5.
# Switch-case-break, ABI,
# przekazanie argumentow i wywolanie funkcji jezyka C.
#
# Program ma wykonac wybrana operacje logiczna lub arytmetyczna oraz wyswietlic:
# jej nazwe, argumenty oraz wynik.
#
# Argumenty do programu nalezy przekazac jako parametry z linii komend:
#
# ./swcs arg1 arg2 nr_operacji_logicznej

.globl	main

.section  .note.GNU-stack, "", @progbits

#################################################################
#
# Alokacja pamieci - zmienne statyczne z nadana wartoscia poczatkowa.

.data

str_and:	.asciz	"%u AND %u = %u\n"
str_or:		.asciz	"%u OR %u = %u\n"
str_xor:	.asciz	"%u XOR %u = %u\n"
str_add:	.asciz	"%u ADD %u = %u\n"
str_def:	.asciz	"DEFAULT\n"

arg_1:		.long	0
arg_2:		.long	0
result:		.long	0
case_no:	.long	0

# --- 2b ---
# Tablica skokow - adresow kolejnych sekcji switcha.
#			0	    1		2	 3	      4
jump_table: .quad  case_default,case_default,case_and,case_default,case_or,case_default,case_xor,case_default,case_add,case_default

#################################################################
#
# program glowny

.text

main:

# W celu zachowania zgodnosci z ABI i funkcjami z GNU C Library
# wierzcholek stosu powinien byc wyrownany do granicy 16 bajtow
# (8-bajtowy adres powrotu + 8-bajtowa ramka stosu, ew. odkladanie
# na stos 16-bajtowych elementow).
# Ramki stosu nie tworzymy, wiec %rsp nalezy obnizyc o 8 bajtow.

sub	$8 , %rsp

# --- 1b --- Opcjonalnie:
#
# sprawdz, czy z linii komend przekazano trzy parametry,
# jesli nie - wyjdz (opcjonalnie zwracajac -1 w %eax).

cmp 	$4 , %edi 	#czy przekazano 3 parametry? arg w %edi
je	convert_argv
add	$8 , %rsp	#jes;o moe - wyjdz z kodem bledu 255
mov	$255 , %eax
ret


convert_argv:

# --- 1a --- Przekazywanie parametrow z linii komend.
#
# Konwertuj przekazane parametry (argv) z ciagu tekstowego na liczbe calkowita,
# np. jedna z funkcji biblioteki stdlib (np. atoi, strtol).

#argv w %rsi - %rsi jest nadpisywany przez funkcje biblioteczne

mov 	%rsi , %rbx
mov	8(%rsi) , %rdi
call	atoi
mov	%eax , arg_1

# Analogicznie konwersje kolejnych parametrow:

mov 	16(%rbx) , %rdi
call 	atoi
mov 	%eax , arg_2


mov 	24(%rbx) , %rdi
call 	atoi




# --- 2a --- Switch - Case.
#
# Sprawdz, czy podany nr przypadku miesci sie w stablicowanym zakresie.

cmp	$8 , %eax
ja	case_default

# Czesc wspolna dla wszystkich przypadkow (za wyjatkiem default - mozna zoptymalizowac).

mov	arg_1 , %esi
mov	arg_2 , %edx
mov	%edx , %ecx

# --- 2c ---
#
# Skok posredni - do adresu odczytanego z tablicy (do odpowiedniego przypadku).

jmp	*jump_table( , %eax , 8)

# W kazdym z przypadkow (oprocz default) wykonaj odpowiednia operacje
# logiczna/arytmetyczna oraz przekaz niezbedne argumenty do funkcji printf.

case_and:
and	%esi , %ecx
mov	$str_and , %rdi
jmp	brk

case_or:
or	%esi , %ecx
mov	$str_or , %rdi
jmp	brk

case_xor:
xor	%esi , %ecx
mov	$str_xor , %rdi
jmp	brk

case_add:
add	%esi , %ecx
mov	$str_add , %rdi
jmp	brk

case_default:
mov	$str_def , %rdi

brk:

# Czesc wspolna dla wszystkich przypadkow:
# wywolaj funkcje printf z uprzednio umieszczonymi w odpowiednich rejestrach (wg ABI):
# adresem ciagu, argumentami i wynikiem operacji.
# Nie sa uzywane typy zmiennoprzecinkowe i rejestry wektorowe (%xmm) wiec %eax=0.

xor	%eax , %eax
call	printf

# Przesun wskaznik stosu o 8 bajtow w gore aby "ret" prawidlowo sciagnal adres powrotu.

add	$8 , %rsp

# Powrot z main, zwroc w %eax kod bledu.
xor	%eax , %eax
ret

#################################################################

