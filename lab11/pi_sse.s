.section .note.GNU-stack, "", @progbits
.globl	main

# Liczba sumowanych par ("+" i "-") elementow.

.equ	N , 1000000000
.equ	NF, N * 6

.data

nfop:		.quad	NF
ndiv:		.double 0.000000001
timetab:	.double	0.0, 0.0, 0.0
mxcsr:		.long	0
str1:		.string "PI_com = %3.20lf\nUSER CPU TIME = %lf s\nGFLOPS = %2.2lf\n"

# Wyrownanie danych do granicy 16 bajtow.

.align  16

suma:		.double   0.0, 0.0
mianownik:	.double   1.0, 3.0
licznik:	.double   4.0, -4.0
plus_2:		.double   4.0, 4.0

.text

main:

sub	$8 , %rsp

# Rozpocznij pomiar czasu.

call	init_time

mov  $N , %rcx

# Ustaw sposob zaokraglania, bity 14 i 13:
# 00 round to nearest,
# 01 round down toward –INF,
# 10 round up toward +INF,
# 11 round toward zero or truncate.

stmxcsr	mxcsr(%rip)
andl	$0xFFFF9FFF , mxcsr(%rip)
orl	$0x00000000 , mxcsr(%rip)
ldmxcsr	mxcsr(%rip)

# Wartosci poczatkowe rejestrow:

movapd   suma(%rip) , %xmm0
movapd   licznik(%rip) , %xmm1
movapd   plus_2(%rip) ,  %xmm2
movapd   mianownik(%rip) , %xmm3
movapd   %xmm1 , %xmm4			#kopia licznika
#movapd  %xmm1 , %xmm11			#druga kopia


# Obliczanie wartosci PI:
#
# +(1/1) - (1/3) + (1/5) - (1/7) + (1/9) + ... => PI/4
# +(4/1) + (-4/3) + (4/5) + (-4/7) + (4/9) + ... => PI/4
#
# Dwa elementy ("+" i "-") szeregu obliczane sa:
#
# a) sekwencyjnie - jeden po drugim (w jednym przebiegu petli - analogicznie jak w lab. 10. - FPU),
# b) sekwencyjnie - w sposob "zoptymalizowany" (podstawienie dodatkowych rejestrow - usuniecie zaleznosci),
# c) jednoczesnie - przetwarzajac dwie liczby typu double przechowywane w rejestrze %xmm (128 bitow)
#    instrukcjami wektorowymi SSE.

for_loop:

# wersja a),  naiwna:

divpd	%xmm3 , %xmm1	# licznik = licznik / mianownik
addpd	%xmm1 , %xmm0	# suma += licznik / mianownik
movapd	%xmm4 , %xmm1	# przywroc licznik
addpd	%xmm2 , %xmm3	# mianownik += 2.0

#divsd	%xmm3 , %xmm11	# licznik = licznik / mianownik
#subsd	%xmm11 , %xmm0	# suma -= licznik / mianownik
#movsd	%xmm4 , %xmm11	# przywroc licznik
#addsd	%xmm2 , %xmm3	# mianownik += 2.0

dec	%rcx
jnz	for_loop

# Zapisz wynik.
haddpd %xmm0, %xmm0
movsd	%xmm0 , suma(%rip)

# Zakoncz pomiar czasu.

lea	timetab(%rip) , %rdi
call	read_time

# Wydrukuj obliczona wartosc i zmierzony czas.

lea	str1(%rip) , %rdi
movsd	suma(%rip) , %xmm0
movsd	timetab+8(%rip) , %xmm1

mov	nfop(%rip) , %rax
cvtsi2sd %rax , %xmm2
divsd	%xmm1 , %xmm2
movsd	ndiv(%rip) , %xmm3
mulsd	%xmm3 , %xmm2

mov	$3 , %eax
call	printf

add	$8 , %rsp
ret
