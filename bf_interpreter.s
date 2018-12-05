.bss
program: .zero 30000 # space for the program
cells: .zero 30000 # cells for execution

.data
intro: .asciz "\n------------------------------\n\x1b[91m.-<[\x1b[95m brain-4k interpreter \x1b[91m]>+,    \x1b[0m \n------------------------------\n"
prompt: .asciz "\x1b[96m> bf: \x1b[0m"
format_command: .asciz " %lc"
format_num_in: .asciz "%ld"
format_line: .asciz "%s"
formatout: .asciz "%d \n"

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

  cmpb $'+', (%r12)
  je plus
  cmpb $'-', (%r12)
  je minus
  cmpb $'.', (%r12)
  je dot
  cmpb $',', (%r12)
  je comma
  cmpb $']', (%r12)
  je angle_br_r
  cmpb $'[', (%r12)
  je angle_br_l
  cmpb $'>', (%r12)
  je angle_br_r
  cmpb $'<', (%r12)
  je angle_br_l

  jmp jumptable_end

  plus: # +
    incq (%r13)
    jmp jumptable_end

  minus: # -
    decq (%r13)
    jmp jumptable_end

  dot: # .
    movq (%r13), %rsi
    movq $formatout, %rdi
    movq $0, %rax
    call printf
    jmp jumptable_end

  comma: # ,
    leaq (%r13), %rsi
    movq $format_num_in, %rdi
    movq $0, %rax
    call scanf
    jmp jumptable_end

  square_br_r: # ]
    cmpq $0, (%r13)
    jmp jumptable_end
  # jump back to the command after [ if non-zero

  square_br_l: # [
    cmpq $0, (%r13)
    jmp jumptable_end
  # jump to the command after ] if zero

  angle_br_r: # >
    addq $8, %r13
    jmp jumptable_end

  angle_br_l: # <
    subq $8, %r13
    jmp jumptable_end

jumptable_end:
  incq %r12

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

  movq $cells, %r13
  movq $program, %r12

  loop_input:
    # prompt input from user
    movq $prompt, %rdi
    movq $0, %rax
    call printf

    # allocate space for input and read input
    movq %r12, %rsi
    movq $format_line, %rdi
    movq $0, %rax
    call scanf

    loop_instruction:
      call jumptable
      cmpq $0, (%r12)

      je loop_input
      jmp loop_instruction

  end:
  call exit
