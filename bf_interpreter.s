.data
intro: .asciz "\n------------------------------\n\x1b[91m.-<[\x1b[95m brain-4k interpreter \x1b[91m]>+,    \x1b[0m \n------------------------------\n"
prompt: .asciz "\x1b[96m> bf: \x1b[0m"
format_command: .asciz " %lc"
format_num_in: .asciz "%ld"
format_line: .asciz " %s"
formatout: .asciz "%d \n"

program: .zero 30000 # space for the program
cells: .zero 30000 # cells for execution

word: .byte 1

# The eight language commands each consist of a single character:
# Character 	Meaning
# > 	increment the data pointer (to point to the next cell to the right).
# < 	decrement the data pointer (to point to the next cell to the left).
# + 	increment (increase by one) the byte at the data pointer.
# - 	decrement (decrease by one) the byte at the data pointer.
# . 	output the byte at the data pointer.
# , 	accept one byte of input, storing its value in the byte at the data pointer.
# [ 	if the byte at the data pointer is zero, then instead of moving the instruction pointer forward to the next command, jump it forward to the command after the matching ] command.
# ] 	if the byte at the data pointer is nonzero, then instead of moving the instruction pointer forward to the next command, jump it back to the command after the matching [ command.
# Source: Wikipedia

.text

jumptable:
  pushq %rbp
  movq %rsp, %rbp

  cmp $'+', %rdi
  je plus
  cmp $'-', %rdi
  je minus
  cmp $'.', %rdi
  je dot
  cmp $',', %rdi
  je comma
  cmp $']', %rdi
  je angle_br_r
  cmp $'[', %rdi
  je angle_br_l
  cmp $'>', %rdi
  je angle_br_r
  cmp $'<', %rdi
  je angle_br_l

  jmp end

  plus: # +
    incq (%rbp)
    jmp jumptable_end

  minus: # -
    decq (%rbp)
    jmp jumptable_end

  dot: # .
    movq (%rbp), %rsi
    movq $formatout, %rdi
    movq $0, %rax
    call printf
    jmp jumptable_end

  comma: # ,
    leaq (%rbp), %rsi
    movq $format_num_in, %rdi
    movq $0, %rax
    call scanf
    jmp jumptable_end

  square_br_r: # ]
    cmpq $0, (%rbp)
    jmp jumptable_end
  # jump back to the command after [ if non-zero

  square_br_l: # [
    cmpq $0, (%rbp)
    jmp jumptable_end
  # jump to the command after ] if zero

  angle_br_r: # >
    addq $word, %rbp
    jmp jumptable_end

  angle_br_l: # <
    subq $word, %rbp
    jmp jumptable_end

jumptable_end:
  movq %rbp, %rsp
  popq %rbp
  ret

.global main

main:
  # initialize stack pointer
  movq %rsp, %rbp

  movq $intro, %rdi
  movq $0, %rax
  call printf

  loop:
    # prompt input from user
    movq $prompt, %rdi
    movq $0, %rax
    call printf

    # allocate space for input and read input
    subq $8, %rsp
    leaq (%rsp), %rsi
    movq $format_command, %rdi
    movq $0, %rax
    call scanf

    movq (%rsp), %rdi

    call jumptable
    call loop

  end:
  call exit
