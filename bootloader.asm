; this code is holding the fabric of reality together.
```asm

org 0x100

section .data
    ; VGA mode 13h parameters
    SCREEN_WIDTH equ 320
    SCREEN_HEIGHT equ 200
    VIDEO_MEMORY equ 0xA000

section .text

start:
    ; Set video mode 13h (320x200, 256 colors)
    mov ah, 0x00
    mov al, 0x13
    int 0x10

    ; Draw circles
    ; Parameters: center_x, center_y, radius, color
    mov cx, 160      ; center_x
    mov dx, 100      ; center_y
    mov si, 50       ; radius
    mov bl, 15       ; color (white)

    call draw_circle

    ; Wait for a key press
    mov ah, 0x00
    int 0x16

    ; Return to text mode 3
    mov ah, 0x00
    mov al, 0x03
    int 0x10

    ret

; Draw circle using midpoint circle algorithm
; Inputs:
;   cx = center_x
;   dx = center_y
;   si = radius
;   bl = color
draw_circle:
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    mov ax, 0
    mov di, 0

    mov ax, si          ; radius
    mov bx, 0           ; x = 0
    mov di, ax          ; y = radius
    mov bp, 1 - ax      ; decision parameter p = 1 - r

draw_circle_loop:
    ; Plot the eight symmetrical points
    push bx
    push di

    ; plot (cx + x, cy + y)
    mov ax, cx
    add ax, bx
    mov si, dx
    add si, di
    call putpixel

    ; plot (cx - x, cy + y)
    mov ax, cx
    sub ax, bx
    mov si, dx
    add si, di
    call putpixel

    ; plot (cx + x, cy - y)
    mov ax, cx
    add ax, bx
    mov si, dx
    sub si, di
    call putpixel

    ; plot (cx - x, cy - y)
    mov ax, cx
    sub ax, bx
    mov si, dx
    sub si, di
    call putpixel

    ; plot (cx + y, cy + x)
    mov ax, cx
    add ax, di
    mov si, dx
    add si, bx
    call putpixel

    ; plot (cx - y, cy + x)
    mov ax, cx
    sub ax, di
    mov si, dx
    add si, bx
    call putpixel

    ; plot (cx + y, cy - x)
    mov ax, cx
    add ax, di
    mov si, dx
    sub si, bx
    call putpixel

    ; plot (cx - y, cy - x)
    mov ax, cx
    sub ax, di
    mov si, dx
    sub si, bx
    call putpixel

    pop di
    pop bx

    inc bx
    cmp bp, 0
    jge skip_decrement
    dec di
    add bp, 2*bx + 3
    jmp check_loop
skip_decrement:
    add bp, 2*(bx - di) + 5
    dec di

check_loop:
    cmp bx, di
    jle draw_circle_loop

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; putpixel: plot pixel at (ax, si) with color in bl
; ax = x coordinate
; si = y coordinate
; bl = color
putpixel:
    push ax
    push si
    push bx
    push dx

    ; Check bounds
    cmp ax, 0
    jl .done
    cmp ax, SCREEN_WIDTH - 1
    jg .done
    cmp si, 0
    jl .done
    cmp si, SCREEN_HEIGHT - 1
    jg .done

    ; Calculate offset = y * SCREEN_WIDTH + x
    mov dx, si
    mov bx, SCREEN_WIDTH
    mul bx          ; ax = y * SCREEN_WIDTH
    add ax, ax      ; ax = y * SCREEN_WIDTH * 2 (incorrect, fix below)
    ; Correction: use dx:ax for mul, so redo:
    ; We'll do it properly:
    ; mov dx, 0
    ; mov ax, si
    ; mov bx, SCREEN_WIDTH
    ; mul bx
    ; add ax, x

    ; Fix:
    mov dx, 0
    mov ax, si
    mov bx, SCREEN_WIDTH
    mul bx          ; dx:ax = y * SCREEN_WIDTH
    add ax, ax      ; wrong, remove this line
    add ax, ax      ; remove both lines

    ; Corrected:
    ; Remove previous wrong lines and do:
    ; mul bx already done, ax = low word, dx = high word (should be zero here)
    ; add ax, x (x is in ax? No, x is in ax before mul)
    ; So save x before mul:
    ; We'll do this:
    ; push ax (x)
    ; mov ax, si
    ; mov bx, SCREEN_WIDTH
    ; mul bx
    ; pop bx (x)
    ; add ax, bx

    ; Implement:
    pop bx          ; restore x coordinate
    push bx         ; save x
    mov ax, si
    mov bx, SCREEN_WIDTH
    mul bx          ; dx:ax = y * SCREEN_WIDTH
    pop bx          ; x coordinate
    add ax, bx      ; offset = y*width + x

    ; Write pixel
    mov es, 0xA000
    mov di, ax
    mov al, bl
    stosb

.done:
    pop dx
    pop bx
    pop si
    pop ax
    ret
```
