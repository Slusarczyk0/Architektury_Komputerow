.section  .note.GNU-stack, "", @progbits

.globl gcd

.text

.type	gcd,@function

gcd:
sub	$8 , %rsp

# Zabezpiecz odpowiednie rejestry przed nadpisaniem
# i wywolaj print_call.

push 	%rsi
push 	%rdi
call 	print_call
pop	%rdi
pop	%rsi


# Algorytm Euklidesa:
#
# unsigned int GCD(unsigned int a, unsigned int b)
# {
#   if (b==0) return a;
#   else GCD(b, a % b);
#  }

cmp	$0 , %esi	# b=0?
je	return_gcd	# jesli tak - wyjdz
mov 	%edi , %eax	# mlodsza czesc dzielnej = a
xor	%edx , %edx	# starsza czesc dzielnej = 0
div 	%esi		# a/b
mov 	%esi , %edi	# b w miejsce a
mov	%edx , %esi	#modulo w miejsce b
call 	gcd

return_gcd:

# Zabezpiecz odpowiednie rejestry przed nadpisaniem
# i wywolaj print_ret.

push 	%rsi
push 	%rdi
call 	print_ret
pop	%rdi
pop	%rsi


# Zwroc obliczona wartosc w %eax.

mov	%edi , %eax	#zwroc a w %eax


add	$8 , %rsp
ret

