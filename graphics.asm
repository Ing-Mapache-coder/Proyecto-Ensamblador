;==============================================================================
; SPACE INVADERS - GRAPHICS.ASM
; Funciones para manejo de gráficos VGA 13h
;==============================================================================

.MODEL SMALL

;------------------------------------------------------------------------------
; CONSTANTES
;------------------------------------------------------------------------------
VIDEO_SEG EQU 0A000h            ; Segmento de memoria de video
SCREEN_WIDTH EQU 320            ; Ancho de pantalla
SCREEN_HEIGHT EQU 200           ; Alto de pantalla

;------------------------------------------------------------------------------
; SEGMENTO DE CÓDIGO
;------------------------------------------------------------------------------
.CODE

;------------------------------------------------------------------------------
; InitGraphics: Inicializa el modo gráfico VGA 13h (320x200, 256 colores)
;------------------------------------------------------------------------------
PUBLIC InitGraphics
InitGraphics PROC
    PUSH AX
    
    MOV AH, 0                   ; Función: establecer modo de video
    MOV AL, 13h                 ; Modo 13h (320x200, 256 colores)
    INT 10h                     ; Llamada al BIOS
    
    POP AX
    RET
InitGraphics ENDP

;------------------------------------------------------------------------------
; ClearScreen: Limpia la pantalla (rellena con color negro)
;------------------------------------------------------------------------------
PUBLIC ClearScreen
ClearScreen PROC
    PUSH AX
    PUSH CX
    PUSH DI
    PUSH ES
    
    MOV AX, VIDEO_SEG
    MOV ES, AX                  ; ES apunta a memoria de video
    XOR DI, DI                  ; DI = 0 (inicio de video)
    
    MOV CX, 32000               ; 320x200 = 64000 bytes / 2
    XOR AX, AX                  ; Color negro
    
    REP STOSW                   ; Llenar memoria de video
    
    POP ES
    POP DI
    POP CX
    POP AX
    RET
ClearScreen ENDP

;------------------------------------------------------------------------------
; SetPixel: Dibuja un píxel en la pantalla
; Entrada: BX = X, CX = Y, AL = Color
;------------------------------------------------------------------------------
PUBLIC SetPixel
SetPixel PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH DI
    PUSH ES
    
    ; Verificar límites
    CMP BX, SCREEN_WIDTH
    JAE PixelOutOfBounds
    CMP CX, SCREEN_HEIGHT
    JAE PixelOutOfBounds
    
    ; Calcular offset: Y * 320 + X
    MOV AX, CX
    MOV DX, SCREEN_WIDTH
    MUL DX                      ; AX = Y * 320
    ADD AX, BX                  ; AX = Y * 320 + X
    MOV DI, AX
    
    ; Establecer segmento de video
    MOV AX, VIDEO_SEG
    MOV ES, AX
    
    ; Recuperar color de la pila
    POP ES
    POP DI
    POP DX
    POP CX
    POP BX
    POP AX
    
    PUSH ES
    PUSH DI
    PUSH AX
    
    MOV AX, VIDEO_SEG
    MOV ES, AX
    MOV DI, BX                  ; Usar el offset calculado antes
    
    POP AX                      ; Recuperar color
    STOSB                       ; Escribir píxel
    
PixelOutOfBounds:
    POP DI
    POP ES
    POP DX
    POP CX
    POP BX
    POP AX
    RET
SetPixel ENDP

;------------------------------------------------------------------------------
; DrawBox: Dibuja un rectángulo relleno
; Entrada: BX = X, CX = Y, DL = ancho, DH = alto, AL = color
;------------------------------------------------------------------------------
PUBLIC DrawBox
DrawBox PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI

    MOV SI, 0                   ; Contador Y (word, pero usaremos solo parte baja)
    
DrawBoxLoopY:
    MOV AL, DH
    CMP BYTE PTR SI, AL         ; compara solo parte baja (forzando byte)
    JAE DrawBoxEnd
    
    MOV DI, 0                   ; Contador X
    
DrawBoxLoopX:
    MOV AL, DL
    CMP BYTE PTR DI, AL
    JAE DrawBoxNextY

    PUSH AX
    PUSH BX
    PUSH CX

    MOV AX, BX
    ADD AL, BYTE PTR DI
    MOV BL, AL

    MOV AX, CX
    ADD AL, BYTE PTR SI
    MOV CL, AL

    CALL SetPixel

    POP CX
    POP BX
    POP AX

    INC DI
    JMP DrawBoxLoopX

DrawBoxNextY:
    INC SI
    JMP DrawBoxLoopY

DrawBoxEnd:
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
DrawBox ENDP

;------------------------------------------------------------------------------
; DrawSprite: Dibuja un sprite 8x8
; Entrada: BX = X, CX = Y, AL = color
;------------------------------------------------------------------------------
PUBLIC DrawSprite
DrawSprite PROC
    PUSH DX
    
    MOV DL, 8                   ; Ancho
    MOV DH, 8                   ; Alto
    CALL DrawBox
    
    POP DX
    RET
DrawSprite ENDP

END