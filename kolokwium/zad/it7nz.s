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
counter:	.byte	0
i_counter: 	.byte	40


tab:	.long	0, 8, 7, 0, 3, 0, 4, 0

#################################################################

.text

main:
sub	$8 , %rsp

# Przykladowe etapy zadania.

# Inicjuj zmienne wartosciami poczatkowymi.
mov 	%rsi, %rbx
mov 	8(%rsi), %rdi
movb $0, counter
mov	counter, %al
movb $1, i_counter
mov	i_counter, %edi


petla:

# Odczytaj w prawidlowy sposob element tablicy.

#mov	tab-8(,%ecx,2) , %eax
mov 	tab( ,%eax,8), %ecx

# Sprawdz czy odczytano wartosc niezerowa. Jesli tak - modyfikuj licznik.
cmp $0, %eax
ja increment

inc %edi
cmpb $8, i_counter
jbe petla

# Zaktualizuj licznik iteracji, sprawdz warunek zakonczenia petli.



#jnz	petla

# Wyswietl wynik (lub stosowny komunikat) funkcja printf,
# przekazujac argumenty zgodnie ABI.

call	printf

increment:
inc %al

mov	$str1, %rdi
#mov	%al,	%rsi
call printf


# Koniec funkcji main.



mov	$str1, %rdi
#mov	%al,	%rsi
add	$8 , %rsp
xor	%eax , %eax
ret

#################################################################

