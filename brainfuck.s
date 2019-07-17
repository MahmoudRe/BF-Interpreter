.bss
# creating memory blocks for brainfuck
MEMO:    .skip    3000

#
NUM:     .byte

.text
format_str: .asciz "%c"

.global brainfuck

# Your brainfuck subroutine will receive one argument:
# a zero termianted string containing the code to execute.
brainfuck:
        pushq %rbp
        movq %rsp, %rbp

        movq %rdi, %r15         #load wanted String in %r15

        call BF_Interpreter

        movq %rbp, %rsp
        popq %rbp
        ret

## %r15 => string of brainfuck code
## %r12 => memory location pointer
## %r14 => to load the variable NUM
## %rbx => free callee saver register for divers uses
## %rcx => counter for the Skiploop 

BF_Interpreter:
        pushq   %rbp
        movq    %rsp, %rbp

        movq    $0, %r12           # set the location pointer (%r12) at 0
        movq    $0, MEMO(%r12)     # %r12 as an index of MEMO


BF_Catalog:
        cmpb $0, (%r15)        #if 0 => end of BF string
        je  End_Compiler

                        
        cmpb $62, (%r15)      #Detect '>'
        je   BF_Next_Loc

                           
        cmpb $60, (%r15)      #Detect '<'
        je   BF_Prev_Loc
                
                
        cmpb $43, (%r15)      #Detect '+'
        je BF_Plus

                
        cmpb $45, (%r15)       #Detect '-'
        je BF_Min

                
        cmpb $46, (%r15)       #Detect '.'
        je BF_Print


        cmpb $44, (%r15)        #Detect ','
        je BF_Comma


        cmpb $91, (%r15)       #Detect '['
        je BF_Open_Bracket

                
        cmpb $93, (%r15)       #Detect ']'
        je BF_Close_Bracket


        inc  %r15              #ignore none brainfuck char
        jmp  BF_Catalog


End_Compiler:
        movq    %rbp, %rsp
        popq    %rbp

        ret

BF_Next_Loc:
        inc     %r12            # Loc pointer (r12) ++
        inc     %r15            # Next char of BF string
        jmp     BF_Catalog      

BF_Prev_Loc:
        dec     %r12            # Loc pointer (r12) --
        inc     %r15            # Next char of BF string
        jmp     BF_Catalog

BF_Plus:
        //incq     MEMO(%r12)      # increase the number in index (%r12)

        // code optimaisation
        // increasing just the last byte should be a bit faster than increasing the whole quad

        incb    MEMO(%r12)      # increase the number in index (%r12)
        inc     %r15            # Next char of BF string
        jmp     BF_Catalog

BF_Min:
        //decq     MEMO(%r12)      # increase the number in index (%r12)

        // code optimaisation
        // decreasing just the last byte should be a bit faster than increasing the whole quad

        decb    MEMO(%r12)      # increase the number in index (%r12)
        inc     %r15            # Next char of BF string
        jmp     BF_Catalog


BF_Print:
        
        /*
        movzb MEMO(%r12), %rsi
        movq $format_str, %rdi
        movq $0, %rax 
        call printf 
        */
        

        // code optimization
        // We don't know how complex the printf in C is implemented.
        // in this case use syscall for a simple print
        
        mov     $NUM, %r14      # insialize byte memory for %r14

        # copy the value to the memory location of %r14
        movq    MEMO(%r12), %rbx  
        movb    %bl, (%r14)

        movq    $1, %rax       # syscall is 1 => SYS_WRITE
        movq    $1, %rdi       # 1sr arg 1 => STOUT (Standard output)
        movq    %r14, %rsi     # 2nd arg is the ASCII char that have value = (%r14)
        movq    $1, %rdx       # 3ed arg is the length
        syscall


        inc     %r15            # Next char of BF string
        jmp     BF_Catalog

BF_Comma:
        movq $0, %rax            # prepair for scanning
        leaq MEMO(%r12), %rsi    # load effective address in 2nd arg to save the scanned value
        movq $format_str, %rdi   # 1st arg is the format_str and expecting an ASCII char
        call scanf

        inc %r15                # Next char
        jmp  BF_Catalog


BF_Open_Bracket:
        // code optimization (from 16sec to under 5sec for Hanio test)
        // add the stage to check if the next two char '-' and ']'
        // if so than just skip this and make the MEMO block 0

        cmpb    $0, MEMO(%r12)      #if the memory block already 0
        je      BF_SkipLoop         #skip all the content of this bracket

        pushq     %r15       # save the position of the pointer (%r15)
        inc       %r15       # next char after '['

        cmpb    $45, (%r15)     # if the next char is '-'
        je      BF_Open_Bracket_Exception

        jmp     BF_Catalog


        BF_Open_Bracket_Exception:
        decq    MEMO(%r12)              # decreasing the value in %r12
        inc     %r15                    # next character

        cmpb    $93, (%r15)            # if the next char is ']'
        je      BF_Open_Bracket_Exception2

        jmp     BF_Catalog

        BF_Open_Bracket_Exception2:
        movb    $0, MEMO(%r12)      # make the current MEMO block 0
        popq    %rbx            # pop now the position of pointer at '['

        incq     %r15            # shift the pointer (r15) after the ']'
        jmp     BF_Catalog          # continue and skip the loop



#save the location of %r15 in %r13
BF_Close_Bracket:
        popq    %rbx            # pop now the position of pointer at '['

        cmpb    $0, MEMO(%r12)  # check if this the end of the loop
        je      End_Bracket

        pushq   %rbx
        movq    %rbx, %r15      # move the pointer (%r15) back to '['
        inc     %r15            # next char after '['
        jmp     BF_Catalog

End_Bracket:
        inc     %r15            # next char after ']'
        jmp     BF_Catalog


#in this loop we skip the brackets with all its contents
# %rax => counter for nested brackets
BF_SkipLoop:
        movq    $0, %rcx      # set the counter at 0

        Loop:
        inc     %r15          # next char

        cmpb    $91,(%r15)        # if this char is '['
        je      incrementRCX      # increment the counter

        cmpb    $93,(%r15)        #if this char is ']'
        je      decrementRCX      # decrement the counter

        jmp     Loop


        incrementRCX:
        inc     %rcx           #increse the counter
        jmp     Loop

        decrementRCX:
        cmp     $0, %rcx       #if the counter is 0, end this loop
        je      Loop_END

        dec     %rcx           #increse the counter
        jmp     Loop

        Loop_END:
        incq    %r15            # next char
        jmp     BF_Catalog



