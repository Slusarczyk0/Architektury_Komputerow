.globl main

.data
# Tablica 4 ułamków typu double (8 bajtów każdy)
tab:        .double 2.0, 4.0, 6.0, 8.0   # Suma = 20.0, Średnia = 5.0
rozmiar:    .long   4                    # Liczba elementów (32-bity)
wynik:      .double 0.0

str_out:    .string "Srednia wynosi: %lf\n"

.text
main:
    push %rbp

    # 1. Inicjalizacja
    finit                   # Reset FPU
    fldz                    # Wrzucamy 0.0 na stos FPU (ST(0) - nasz akumulator)
    
    # Do iteracji używamy %rcx (64-bit), co jest bezpieczniejsze przy adresowaniu pamięci
    movslq rozmiar, %rcx    # Wczytujemy rozmiar (4) do rejestru RCX ze znakiem

petla_sumy:
    # 2. Odczyt elementu i dodanie do ST(0)
    # Kiedy %rcx = 4: tab - 8 + (4 * 8) = tab + 24 (czwarty element)
    # Kiedy %rcx = 1: tab - 8 + (1 * 8) = tab + 0  (pierwszy element)
    
    faddl tab-8(,%rcx,8)    # POBRANIE SPARTANEM: Baza - 8 + (Licznik * 8)
    
    # 3. Zmniejszenie licznika pętli
    dec %rcx
    jnz petla_sumy

    # 4. Dzielenie przez liczbę elementów
    # W ST(0) mamy teraz pełną sumę (20.0)
    fidivl rozmiar          # Dzielimy ST(0) przez całkowitoliczbową wartość z pamięci (4)
    fstpl wynik             # Zapisujemy wynik (5.0) do zmiennej i zdejmujemy z FPU

    # 5. Wyświetlenie wyniku (printf)
    mov $str_out, %rdi      # Wskaźnik na łańcuch znaków
    movsd wynik, %xmm0      # Przekazanie zmiennej double do rejestru wektorowego
    mov $1, %eax            # Używamy 1 rejestru zmiennoprzecinkowego (XMM0)
    call printf

    pop %rbp
    xor %eax, %eax
    ret
