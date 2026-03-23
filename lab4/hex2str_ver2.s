#################################################################
#
# Laboratorium 2a. Konwersja liczby calkowitej bez znaku
# do postaci ciagu tekstowego (reprezentacja w systemie szesnastkowym).

.globl _start

#################################################################
#
# Alokacja pamieci - zmienne statyczne, 8/16/32/64-bitowe,
# z nadana wartoscia poczatkowa.

.data

# en.wikipedia.org/wiki/Hexspeak
# en.wikipedia.org/wiki/Magic_number_(programming)

var8:	.byte	237
var16:	.word	57005
var32:	.long	4276994270
var64:	.quad	13464654573299691533

str:	.ascii	"val = ................h\n"
.equ	strlen, . - str

#################################################################
#
# Program glowny.

 .text

_start:

	xor	%eax , %eax

# Przekaz tylko niezbedne argumenty do funkcji konwertujacej.
# Przykladowo:
# w %rax (odpowiedniej dlugosci) - liczbe podlegajaca konwersji,
# w %rdi - adres bufora (pozycji odpowiadajacej cyfrze jednosci).

	mov 	var32 , %eax
	mov	$str+12 , %rdi 

# W przypadku konwersji typow wielobajtowych przekaz
# w rejestrze %ecx - rozmiar konwertowanego typu danych w bajtach: (1),2,4,8.

	mov 	$4, %ecx


# Wywolaj funkcje konwertujaca.

	call	convert	

# Wyswietl wynik (system_call nr 1).

	mov	$1 , %eax
	mov	%eax , %edi
	mov	$str , %rsi
	mov	$strlen,%edx
	syscall

# Zakoncz program (system_call nr 60).

	mov	$60,%eax
	xor	%edi,%edi
	syscall

#################################################################
#
# Zadanie --- 3 ---
#
# Konwertuj wielobajtowy typ danych.
#
# Argumenty:
# liczba w rejestrze %rax (odpowiedniej dlugosci),
# adres zapisu w %rdi,
# liczba bajtow do konwersji w %ecx.
#
# Funkcja moze wywolywac "convert_byte" z zadania 2.
# Ew. funkcje z zadan 2. i 3. mozna scalic w jedna i zoptymalizowac.
#
# Zwracana wartosc: - (zapis w pamieci) .
# Nadpisywane rejestry: ustalic.

convert:

	mov	%eax , %r9d 	#kopia %eax w %r9d
	and 	$0xFF , %eax # zostaw najmlodszy bajt (0-255,0x00-0xFF) w %elx
	mov	lut( , %eax, 2) , %ax # odczytaj do %ax element lok_up table z adresu lut%+%eax*2 
	mov 	%ax , (%rdi,%rcx,2) 	#zapis %ax do pamieci pod adres %rdi+%rcx*2
	mov	%r9d, %eax	#przywroc pierwotna wartosc eax
	shr 	$8 , %eax	#kolejny bajt na miejsce najmldoszego
	dec 	%ecx
	jnz	convert		#petla od ecx=4 do 1 (wlacznie)

	ret

#################################################################
