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
	mov	$str+20 , %rdi 

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
	call	convert_byte
	mov 	%ax , (%rdi) 	#zapis %ax do pamieci pod adres trzymany w rejestrze %rdi
	mov	%r9d, %eax	#przywroc pierwotna wartosc eax
	shr 	$8 , %eax	#kolejny bajt na miejsce najmldoszego
	sub 	$2, %rdi	#przesun wsakznik zapisu
	dec 	%ecx
	jnz	convert		#petla od ecx=4 do 1 (wlacznie)

	ret

#################################################################
#
# Zadanie --- 2 ---
#
# Konwertuj pojedynczy bajt.
# Argumenty: dane w rejestrze %al, ew. adres zapisu (dwoch bajtow) w %rdi.
#
# Zwracana wartosc: dwa elementy ciagu tekstowego w %ax.
# Nadpisywane rejestry: ustalic.

convert_byte:

	mov 	%al, %r8b 	# kopia %al w %r8b
	and 	$0x0F , %al	# wyzeruj starsze 4 bity %al
	call	convert_nibble 	# konwersja mlodszej polowki bajtu (mlodszych 4 bitow)
	mov 	%al, %ah	# wynik w %ah

	mov	%r8b, %al	# odtworz  pierwotna wartosc %al z %r8b
	shr	$4 , %al
	call 	convert_nibble	# konwertuj starsze 4 bity wynik w %al

	ret

#################################################################
#
# Zadanie --- 1 ---
#
# Konwertuj czterobitowa liczbe (nizszy polbajt, nizsza tetrade, lower nibble...)
# na odpowiadajacy jej kod znaku tablicy ASCII.
#
# Argument:
# 4 mlodsze bity w rejestrze %al (4 starsze musza byc wyzerowane).
#
# Zwracana wartosc: w %al - nr znaku wg tablicy ASCII.
# Nadpisywane rejestry:
#
# Wykonywane dzialanie: if (%al < 10) %al += 48; else %al += 55;
# (realizacja - dowolna).

convert_nibble:

	cmp 	$9 , %al
	ja 	above
	add	$48 , %al
	ret	#albo ret albo jump do returna
#	jmp 	jump

above:
	add 	$55, %al
#jump:
	ret

#################################################################
