.globl main
.equ N, 10

.data
stala_1:    .double 1.0
licznik:    .short  0      # 16-bitowe słowo (pasuje do rejestru CX)
wynik:      .double 0.0
str:        .string "Suma szeregu = %lf\n"

.text
main:                
    push %rbp
    
    mov $N, %rcx           # RCX to nasz iterator 'i' (idziemy od 10 do 1)
    
    finit
    fldz                   # ST(0) = 0.0 (tutaj będziemy kumulować sumę)

for_loop:
    # 1. Musimy przenieść licznik RCX na stos FPU. FPU nie ładuje prosto z rejestrów GPR.
    movw %cx, licznik      # Kopiujemy najniższe 16 bitów z RCX do pamięci

    # 2. Przygotowujemy ułamek: 1.0 / i
    fldl stala_1           # ST(0) = 1.0, ST(1) = akumulator
    filds licznik          # fild ładuje licznik CAŁKOWITY (int16). 
                           # ST(0) = i, ST(1) = 1.0, ST(2) = akumulator

    # 3. Dzielenie i dodawanie
    fdivrp                 # Dzieli ST(1)/ST(0) (czyli 1.0 / i) i zdejmuje ST(0). 
                           # Teraz ST(0) = wynik dzielenia, ST(1) = akumulator sumy
    
    faddp                  # Dodajemy ułamek do akumulatora i redukujemy stos.
                           # Teraz w ST(0) znowu jest powiększony akumulator.

    dec %rcx               # Zmniejsz 'i'
    jnz for_loop           # Jeśli 'i' nie jest równe 0, powtarzaj

    # Po wyjściu z pętli całkowita suma znajduje się na szczycie stosu (ST(0))
    fstpl wynik            # Ściągamy sumę do pamięci jako double

    # Wywołanie printf
    mov $str, %rdi
    movsd wynik, %xmm0     # Kopiujemy double do rejestru SSE
    mov $1, %eax           # Użyto 1 rejestru XMM
    call printf

    pop %rbp
    xor %eax, %eax
    ret