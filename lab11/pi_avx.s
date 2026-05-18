.section .note.GNU-stack, "", @progbits
.globl	main

# Liczba sumowanych par (+ i -) elementow.

.equ	N , 500000000
.equ	NF, N * 12

.data

nfop:		.quad	NF
ndiv:		.double 0.000000001
timetab:	.double	0.0, 0.0, 0.0
mxcsr:		.long	0
str1:		.string "PI_com = %3.20lf\nUSER CPU TIME = %lf s\nGFLOPS = %2.2lf\n"
str2:		.string "Brak AVX\n"

# Wyrownanie danych do granicy 32 bajtow.
.align  32

suma:		.double	0.0,	0.0,	0.0,	0.0
mianownik:	.double	1.0,	3.0,	5.0,	7.0
licznik:	.double	4.0,	-4.0,	4.0,	-4.0
plus_8:		.double	8.0,	8.0,	8.0,	8.0

.text

main:

sub	$8 , %rsp

# Sprawdz czy procesor ma AVX, jesli nie - wyjdz.

mov	$1 , %eax
cpuid
shr	$29 , %ecx
jc	avx
lea	str2(%rip) , %rdi
xor	%eax , %eax
jmp	print

avx:

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

vxorpd	%xmm0 , %xmm0 , %xmm0	# suma = 0
vmovapd	licznik(%rip) , %ymm1
vmovapd	mianownik(%rip) , %ymm2
vmovapd	plus_8(%rip) , %ymm8

# Obliczanie wartosci PI:
#
# +(1/1) - (1/3) + (1/5) - (1/7) + (1/9) + ... => PI/4
#
# Cztery kolejne elementy (dwa "+" i dwa "-") szeregu obliczane sa jednoczesnie.

for_loop:

vdivpd		%ymm2 , %ymm1 , %ymm3		# %ymm3 = licznik / mianownik
vaddpd		%ymm3 , %ymm0 , %ymm0		# suma += %ymm3
vaddpd		%ymm8 , %ymm2 , %ymm2		# mianownik += 8.0

dec %rcx
jnz for_loop

vhaddpd	%ymm0 , %ymm0 , %ymm0
vextractf128	$1 , %ymm0 , %xmm1
vaddpd		%xmm0 , %xmm1 , %xmm2

# Zapisz wynik.

movsd		%xmm2 , suma(%rip)

# Zakoncz pomiar czasu.

lea	timetab(%rip) , %rdi
call	read_time

# Wydrukuj obliczona wartosc i zmierzony czas.

lea	str1(%rip) , %rdi
movsd	suma(%rip) , %xmm0
movsd	timetab+8(%rip) , %xmm1

mov	nfop(%rip) , %rax
cvtsi2sd	%rax , %xmm2
divsd	%xmm1 , %xmm2
movsd	ndiv(%rip) , %xmm3
mulsd	%xmm3 , %xmm2

mov	$3 , %eax

print:

call	printf

add	$8 , %rsp
ret
