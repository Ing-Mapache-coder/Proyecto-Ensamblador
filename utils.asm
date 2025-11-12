;==============================================================================
; SPACE INVADERS - UTILS.ASM
; Funciones auxiliares: delays, conversiones y utilidades
;==============================================================================

.MODEL SMALL

;------------------------------------------------------------------------------
; SEGMENTO DE CÓDIGO
;------------------------------------------------------------------------------
.CODE

;------------------------------------------------------------------------------
; Delay: Genera un retardo temporal
; Entrada: CX = factor de retardo
;------------------------------------------------------------------------------
PUBLIC Delay
Delay PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
DelayOuterLoop:
    PUSH CX
    MOV CX, 0FFFFh
    
DelayInnerLoop:
    NOP
    NOP
    LOOP DelayInnerLoop
    
    POP CX
    LOOP DelayOuterLoop
    
    POP DX
    POP CX
    POP BX
    POP AX
    RET
Delay ENDP

;------------------------------------------------------------------------------
; CoordToOffset: Convierte coordenadas (X,Y) a offset de video
; Entrada: BX = X, CX = Y
; Salida: AX = offset
;------------------------------------------------------------------------------
PUBLIC CoordToOffset
CoordToOffset PROC
    PUSH BX
    PUSH CX
    PUSH DX
    
    ; Offset = Y * 320 + X
    MOV AX, CX                  ; AX = Y
    MOV DX, 320
    MUL DX                      ; AX = Y * 320
    ADD AX, BX                  ; AX = Y * 320 + X
    
    POP DX
    POP CX
    POP BX
    RET
CoordToOffset ENDP

;------------------------------------------------------------------------------
; Random: Genera un número pseudo-aleatorio
; Salida: AX = número aleatorio
;------------------------------------------------------------------------------
PUBLIC Random
Random PROC
    PUSH BX
    PUSH CX
    PUSH DX
    
    ; Usar el reloj del sistema para generar número aleatorio
    MOV AH, 0
    INT 1Ah                     ; Leer contador de reloj
    
    MOV AX, DX                  ; Usar parte baja como semilla
    
    POP DX
    POP CX
    POP BX
    RET
Random ENDP

;------------------------------------------------------------------------------
; WaitForKey: Espera a que se presione una tecla
;------------------------------------------------------------------------------
PUBLIC WaitForKey
WaitForKey PROC
    PUSH AX
    
    MOV AH, 0
    INT 16h                     ; Esperar tecla
    
    POP AX
    RET
WaitForKey ENDP

;------------------------------------------------------------------------------
; CheckKeyPressed: Verifica si hay tecla presionada (sin esperar)
; Salida: ZF = 1 si no hay tecla, ZF = 0 si hay tecla
;------------------------------------------------------------------------------
PUBLIC CheckKeyPressed
CheckKeyPressed PROC
    PUSH AX
    
    MOV AH, 1
    INT 16h                     ; Verificar si hay tecla
    
    POP AX
    RET
CheckKeyPressed ENDP

;------------------------------------------------------------------------------
; ClearKeyboardBuffer: Limpia el buffer del teclado
;------------------------------------------------------------------------------
PUBLIC ClearKeyboardBuffer
ClearKeyboardBuffer PROC
    PUSH AX
    
ClearLoop:
    MOV AH, 1
    INT 16h                     ; Verificar si hay tecla
    JZ ClearDone
    
    MOV AH, 0
    INT 16h                     ; Leer y descartar
    JMP ClearLoop
    
ClearDone:
    POP AX
    RET
ClearKeyboardBuffer ENDP

;------------------------------------------------------------------------------
; PlaySound: Genera un sonido básico usando el altavoz PC
; Entrada: BX = frecuencia, CX = duración
;------------------------------------------------------------------------------
PUBLIC PlaySound
PlaySound PROC
    PUSH AX
    PUSH BX
    PUSH CX
    
    ; Habilitar altavoz
    IN AL, 61h
    OR AL, 3
    OUT 61h, AL
    
    ; Configurar timer
    MOV AL, 0B6h
    OUT 43h, AL
    
    MOV AX, BX
    OUT 42h, AL
    MOV AL, AH
    OUT 42h, AL
    
    ; Esperar duración
    CALL Delay
    
    ; Deshabilitar altavoz
    IN AL, 61h
    AND AL, 0FCh
    OUT 61h, AL
    
    POP CX
    POP BX
    POP AX
    RET
PlaySound ENDP

;------------------------------------------------------------------------------
; Abs: Valor absoluto de un número con signo
; Entrada: AX = número
; Salida: AX = |número|
;------------------------------------------------------------------------------
PUBLIC Abs_val
Abs_val PROC
    CMP AX, 0
    JGE Abs_valEnd
    NEG AX
    
Abs_valEnd:
    RET
Abs_val ENDP

;------------------------------------------------------------------------------
; Min: Retorna el mínimo de dos números
; Entrada: AX, BX
; Salida: AX = min(AX, BX)
;------------------------------------------------------------------------------
PUBLIC Min
Min PROC
    CMP AX, BX
    JLE MinEnd
    MOV AX, BX
    
MinEnd:
    RET
Min ENDP

;------------------------------------------------------------------------------
; Max: Retorna el máximo de dos números
; Entrada: AX, BX
; Salida: AX = max(AX, BX)
;------------------------------------------------------------------------------
PUBLIC Max
Max PROC
    CMP AX, BX
    JGE MaxEnd
    MOV AX, BX
    
MaxEnd:
    RET
Max ENDP

END