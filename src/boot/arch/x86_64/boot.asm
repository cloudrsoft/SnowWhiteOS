; -------------------------------------------------------------------------------------------------
; boot/boot.asm
; -------------------------------------------------------------------------------------------------

[ORG 0x7c00]
[BITS 16]

%include "src/boot/arch/x86_64/defines.asm"

; -------------------------------------------------------------------------------------------------
; Entrypoint for boot loader
; in: dl = bootdrive
entry:
        jmp short loader
        nop

times 0x3b db 0                     ; BIOS parameter block

loader:
        mov [ebpb_drive_number], dl
        xor ax, ax
        mov ds, ax
        mov es, ax
        mov ss, ax
        mov sp, boot_sector_base

        mov ax, 0x3                 ; Clear Screen
		 int 0x10

 		 ;mov ax, 0x4F01
		 ;mov cx, 0x117
		 ;mov bx, 0x07E0
		 ;mov es, bx
		 ;mov di, 0x00
		 ;int 0x10

		 ;mov ax, 0x4F02
		 ;mov bx, 0x4117
		 ;int 0x10

		 ;cli

        call find_root_file

load_file:
        mov ax, [di+0xf]
        mov bx, loader_base

.next_cluster:
        call read_cluster
        cmp ax, 0xfff8
        jb .next_cluster

        jmp 0:loader_base           ; Run loader

; -------------------------------------------------------------------------------------------------
; Reads a sector using LBA
; in:  eax = logical sector #
;      es:bx = destination buffer
; out: eax = next sector #
;      es:bx = destination buffer + sector size
read_sector:
        push si
        push di
        push dx

.retry:
        push eax
        mov di, sp                  ; Save stack pointer

        push byte 0                 ; High-32 bit sector to read
        push byte 0                 ; High-32 bit sector to read
        push eax                    ; Low-32 bit sector to read
        push es                     ; Destination Segment
        push bx                     ; Destination Offset
        push byte 1                 ; Number of sectors
        push byte 16                ; Size of parameter block

        mov si, sp
        mov ah, 0x42                ; Extended Read Sectors from Drive
        mov dl, [ebpb_drive_number]
        int 0x13

        mov sp, di                  ; Restore stack pointer
        pop eax

        jnc .read_ok                ; Check for success

        push ax
        xor ah, ah                  ; Reset Disk Drives
        int 0x13
        pop ax

        mov si, msg_failed
        call bios_print
		 cli
		 hlt

.read_ok:
        inc eax                     ; Increment to next sector
        add bx, 0x200
        jnc .exit

        mov dx, es                  ; Increment to next segment
        add dh, 0x10
        mov es, dx

.exit:
        pop dx
        pop di
        pop si
        ret

; -------------------------------------------------------------------------------------------------
; Read a cluster using LBA
; in:  ax = cluster #
;      bx = destination buffer
; out: ax = next cluster #
;      bx = destination buffer + cluster size
read_cluster:
        push cx
        push dx
        push ax
        sub ax, 2
        mul byte[bpb_sectors_per_cluster]
        mov cx, ax

        xor eax, eax
        mov al, [bpb_fat_count]
        mul word[bpb_sectors_per_fat]
        add ax, [bpb_reserved_sector_count]
        add ax, [bpb_hidden_sector_count]
        add ax, cx

        mov cx, [bpb_root_entry_count]
        shr cx, 4                   ; (root_entry_count * 32) / 512
        add ax, cx

        xor dx, dx
        mov dl, [bpb_sectors_per_cluster]

.next_sector:
        call read_sector
        dec dx
        jne .next_sector

.next_cluster:
        pop ax                      ; Restore original cluster #

        push es
        push bx
        shl ax, 1
        div word[bpb_bytes_per_sector]          ; Remainder stored in dx
        add ax, [bpb_reserved_sector_count]
        add ax, [bpb_hidden_sector_count]

        xor bx, bx
        mov es, bx
        mov bx, temp_sector
        call read_sector

        mov bx, temp_sector
        add bx, dx
        mov ax, [bx]
        pop bx
        pop es

.exit:
        pop dx
        pop cx
        ret

; -------------------------------------------------------------------------------------------------
; Find root file
find_root_file:
        xor eax, eax
        mov al, [bpb_fat_count]
        mul word[bpb_sectors_per_fat]
        add ax, [bpb_reserved_sector_count]
        add ax, [bpb_hidden_sector_count]

        mov dx, [bpb_root_entry_count]
        shr dx, 4                   ; (root_entry_count * 32) / 512

.next_sector:
        mov bx, temp_sector
        mov di, bx
        call read_sector

.next_entry:
        mov si, filename
        mov cx, 0x0b
        repe cmpsb                ; compare ds:si with es:di
        jz .done

        add di, 0x20
        and di, -0x20
        mov bx, temp_sector
        add bx, [bpb_bytes_per_sector]
        cmp di, bx
        jnz .next_entry

        ; End of sector
        dec dx
        jnz .next_sector

        ; End of root entry count
        mov si, msg_no_file
        call bios_print
        jmp $

.done:
        ret

; -------------------------------------------------------------------------------------------------
; Prints a string to the screen
; in: si = address of string
; out: si = end of string
bios_print:
        push ax
        mov ah, 0x0e
.loop:
        lodsb
        cmp al, 0
        je .done
        int 0x10
        jmp .loop
.done:
        pop ax
        ret

; -------------------------------------------------------------------------------------------------
msg_failed db '[SnowWhite OS] Bootloader Read Failure', 13, 10, 0
msg_no_file db '[SnowWhite OS] Bootloader File not Found', 13, 10, 0
filename db 'LOADER  BIN'

; -------------------------------------------------------------------------------------------------
; Footer
times 510-($-$$) db 0    ; Fill boot sector
dw 0xAA55                ; Boot loader signature
