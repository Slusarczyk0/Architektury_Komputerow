.data
txt_out:    .string "Wynik: Y = %lf\n"
x:          .double 3.0
z:          .double 4.0
stala_5:    .double 5.0
wynik_y:    .double 0.0
cw:         .word   0

.text
.global main
main:
    push %rbp
    finit

    # 1. Ustawienie podwójnej precyzji (Double Precision - 53 bity)
    # Bity 8 i 9 w Control Word odpowiadają za Precision Control (PC).
    # Double to wartość binarne 10 (czyli zerujemy bit 8, ustawiamy bit 9).
    fstcw cw
    andw $0xFCFF, cw      # Zerujemy bity 8 i 9 (1111 1100 1111 1111)
    orw  $0x0200, cw      # Ustawiamy bit 9 na 1, bit 8 pozostaje 0 (0000 0010 0000 0000)
    fldcw cw

    # 2. Obliczenia (Notacja RPN na stosie FPU)
    # Liczymy najpierw licznik: x^2 + 5
    fldl x                # ST(0) = x = 3.0
    fldl x                # ST(0) = 3.0, ST(1) = 3.0
    fmulp                 # Mnożymy ST(0) * ST(1), zdejmujemy. ST(0) = 9.0
    
    fldl stala_5          # ST(0) = 5.0, ST(1) = 9.0
    faddp                 # Dodajemy. ST(0) = 14.0 (to jest nasz licznik)

    # Liczymy mianownik: sqrt(z)
    fldl z                # ST(0) = 4.0, ST(1) = 14.0
    fsqrt                 # Pierwiastkujemy ST(0). ST(0) = 2.0 (mianownik)

    # Wykonujemy dzielenie: licznik / mianownik
    # Mamy na stosie: ST(0) = 2.0 (mianownik), ST(1) = 14.0 (licznik)
    fdivrp                # Reverse Divide: ST(1) / ST(0), pop. ST(0) = 7.0

    # 3. Zapis wyniku
    fstpl wynik_y         # Zapisz ST(0) do wynik_y jako double i usuń ze stosu

    # 4. Wywołanie printf (ABI System V x86_64)
    mov $txt_out, %rdi    # RDI = format string
    movsd wynik_y, %xmm0  # Pierwszy argument zmiennoprzecinkowy ląduje w xmm0 (SSE!)
    mov $1, %eax          # AL = 1 (informujemy printf, że używamy 1 rejestru wektorowego)
    call printf

    pop %rbp
    xor %eax, %eax
    ret
