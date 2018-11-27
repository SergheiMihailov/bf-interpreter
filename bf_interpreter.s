.text
prompt: .asciz "bf: "
formatin: .asciz "%d"
formatout: .asciz "%d \n"

plus:

minus:

dot:

comma:

square_br_r:

square_br_l:

angle_br_r:

angle_br_l:

.global main

main:
  loop:
    // initialize stack pointer
    movq %rsp, %rbp

    // prompt input from user
    movq $prompt, %rdi
    movq $0, %rax
    call printf

    // allocate space for input and read input
    subq $8, %rsp
    leaq (%rsp), %rsi
    movq $formatin, %rdi
    movq $0, %rax
    call scanf

  call exit
