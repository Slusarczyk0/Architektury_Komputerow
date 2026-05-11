#################################################################
#
# Na maks. 8 punktow:
# program ma zliczyc i wydrukowac (funkcja printf)
# liczbe wszystkich elementow tablicy o wartosci niezerowej,
#
# kontynuacja (na maks. 10 punktow):
#
#  - wyswietlic komunikat jezeli tablica wypelniona jest samymi zerami.
#
# Zadanie ratunkowe - na maks. 5 punktow: wydrukowanie tekstu "str1"
# z wartosciami (w rejestrach) podanymi przez prowadzacego (funkcja "printf").
#
#################################################################
.section	.note.GNU-stack, "", @progbits
.globl	main

.data

.equ	liczba_elementow, 8
str1:	.asciz	"%u elementow niezerowych\n"
str2:	.asciz	"brak elementow niezerowych\n"
#counter	.byte 	40

tab:	.long	0, 8, 7, 0, 3, 0, 4, 0

#################################################################

.text

main:
sub	$8 , %rsp
mov	$str1, %rdi
mov	$5, %rsi
xor	%eax,%eax
call 	printf
# Przykladowe etapy zadania.

# Inicjuj zmienne wartosciami poczatkowymi.


petla:

# Odczytaj w prawidlowy sposob element tablicy.

#mov	tab-8(,%ecx,2) , %eax

# Sprawdz czy odczytano wartosc niezerowa. Jesli tak - modyfikuj licznik.


# Zaktualizuj licznik iteracji, sprawdz warunek zakonczenia petli.

#jnz	petla

# Wyswietl wynik (lub stosowny komunikat) funkcja printf,
# przekazujac argumenty zgodnie ABI.

#call	printf

# Koniec funkcji main.

add	$8 , %rsp
xor	%eax , %eax
ret

#################################################################

