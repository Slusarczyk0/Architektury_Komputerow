.globl main

.data
# Nasza tablica ułamków typu double (każdy zajmuje 8 bajtów w pamięci)
tablica:    .double 2.0, 4.0, 6.0, 8.0   # Suma = 20.0, Średnia = 5.0

# Rozmiar jako liczba całkowita 32-bitowa (.long)
rozmiar:    .long   4                    

# Miejsce na zapisanie gotowego wyniku
wynik:      .double 0.0                  

.text
main:
    push %rbp

    # ==========================================
    # KROK 1: Inicjalizacja rejestrów i FPU
    # ==========================================
    mov rozmiar, %ecx       # Pobieramy rozmiar (4) do rejestru ECX (Licznik pętli)
    lea tablica(%rip), %rbx # Ustawiamy rejestr RBX jako wskaźnik na pierwszy element
    
    finit                   # Czysty start koprocesora
    fldz                    # Wrzucamy 0.0 na szczyt stosu ST(0). Będzie to nasz "akumulator" sumy.

    # ==========================================
    # KROK 2: Pętla sumująca
    # ==========================================
petla_sumy:
    faddl (%rbx)            # Dodaj wartość double z adresu w RBX do sumy na ST(0)
    add $8, %rbx            # Przesuń wskaźnik o 8 bajtów (bo double ma 64 bity = 8 bajtów)
    
    dec %ecx                # Odejmij 1 od licznika
    jnz petla_sumy          # Skocz z powrotem, jeśli licznik nie osiągnął zera (Jump if Not Zero)

    # ==========================================
    # KROK 3: Dzielenie i zrzut wyniku
    # ==========================================
    # W tym momencie w ST(0) znajduje się suma równa 20.0.
    
    fidivl rozmiar          # Instrukcja "Integer Divide". Automatycznie pobiera 32-bitową 
                            # liczbę z pamięci (4), konwertuje na float i wykonuje ST(0) = ST(0) / 4.0

    fstpl wynik             # Zapisz wynik z ST(0) do zmiennej w pamięci i zrzuć go ze stosu (POP)

    # ==========================================
    # Koniec programu
    # ==========================================
    pop %rbp
    xor %eax, %eax
    ret
