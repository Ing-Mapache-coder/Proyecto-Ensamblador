;==============================================================================
; SPACE INVADERS - PLAYER.ASM
; Control del jugador: movimiento y disparos
;==============================================================================

.MODEL SMALL

;------------------------------------------------------------------------------
; DECLARACIONES EXTERNAS
;------------------------------------------------------------------------------
EXTRN DrawSprite:PROC, DrawBox:PROC

;------------------------------------------------------------------------------
; CONSTANTES
;------------------------------------------------------------------------------
PLAYER_COLOR EQU 2              ; Verde
BULLET_COLOR EQU 15             ; Blanco
MAX_BULLETS EQU 5               ; Máximo de disparos simultáneos
PLAYER_WIDTH EQU 12
PLAYER_HEIGHT EQU 8

;------------------------------------------------------------------------------
; SEGMENTO DE DATOS
;------------------------------------------------------------------------------
.DATA
    player_x DW 160             ; Posición X del jugador (centro)
    player_y DW 180             ; Posición Y del jugador (cerca del fondo)
    
    ; Array de disparos [activo, x, y]
    bullets DB MAX_BULLETS * 3 DUP(0)
    
PUBLIC player_x, player_y, bullets

;------------------------------------------------------------------------------
; SEGMENTO DE CÓDIGO
;------------------------------------------------------------------------------
.CODE

;------------------------------------------------------------------------------
; InitPlayer: Inicializa la posición del jugador
;------------------------------------------------------------------------------
PUBLIC InitPlayer
InitPlayer PROC
    MOV player_x, 160
    MOV player_y, 180
    
    ; Limpiar bullets
    PUSH CX
    PUSH DI
    PUSH ES
    PUSH AX
    
    MOV AX, @DATA
    MOV ES, AX
    LEA DI, bullets
    MOV CX, MAX_BULLETS * 3
    XOR AL, AL
    REP STOSB
    
    POP AX
    POP ES
    POP DI
    POP CX
    RET
InitPlayer ENDP

;------------------------------------------------------------------------------
; DrawPlayer: Dibuja el jugador en su posición actual
;------------------------------------------------------------------------------
PUBLIC DrawPlayer
DrawPlayer PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
    MOV BX, player_x
    MOV CX, player_y
    MOV AL, PLAYER_COLOR
    MOV DL, PLAYER_WIDTH
    MOV DH, PLAYER_HEIGHT
    CALL DrawBox
    
    POP DX
    POP CX
    POP BX
    POP AX
    RET
DrawPlayer ENDP

;------------------------------------------------------------------------------
; MovePlayerLeft: Mueve el jugador a la izquierda
;------------------------------------------------------------------------------
PUBLIC MovePlayerLeft
MovePlayerLeft PROC
    PUSH AX
    
    MOV AX, player_x
    CMP AX, 5
    JLE MoveLeftEnd
    
    SUB player_x, 5
    
MoveLeftEnd:
    POP AX
    RET
MovePlayerLeft ENDP

;------------------------------------------------------------------------------
; MovePlayerRight: Mueve el jugador a la derecha
;------------------------------------------------------------------------------
PUBLIC MovePlayerRight
MovePlayerRight PROC
    PUSH AX
    
    MOV AX, player_x
    CMP AX, 300
    JGE MoveRightEnd
    
    ADD player_x, 5
    
MoveRightEnd:
    POP AX
    RET
MovePlayerRight ENDP

;------------------------------------------------------------------------------
; ShootPlayer: Crea un nuevo disparo
;------------------------------------------------------------------------------
PUBLIC ShootPlayer
ShootPlayer PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH SI
    
    ; Buscar slot libre en el array de disparos
    LEA SI, bullets
    MOV CX, MAX_BULLETS
    
FindFreeSlot:
    CMP BYTE PTR [SI], 0        ; ¿Está inactivo?
    JE FoundSlot
    
    ADD SI, 3                   ; Siguiente disparo (3 bytes)
    LOOP FindFreeSlot
    
    JMP ShootEnd                ; No hay slots libres
    
FoundSlot:
    ; Activar disparo
    MOV BYTE PTR [SI], 1        ; Activo
    
    ; Establecer posición inicial
    MOV AX, player_x
    ADD AX, 6                   ; Centro del jugador
    MOV [SI+1], AL              ; X
    
    MOV AX, player_y
    SUB AX, 2                   ; Encima del jugador
    MOV [SI+2], AL              ; Y
    
ShootEnd:
    POP SI
    POP CX
    POP BX
    POP AX
    RET
ShootPlayer ENDP

;------------------------------------------------------------------------------
; UpdateBullets: Actualiza y dibuja todos los disparos activos
;------------------------------------------------------------------------------
PUBLIC UpdateBullets
UpdateBullets PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    
    LEA SI, bullets
    MOV CX, MAX_BULLETS
    
UpdateBulletLoop:
    CMP BYTE PTR [SI], 0        ; ¿Está activo?
    JE NextBullet
    
    ; Mover disparo hacia arriba
    MOV AL, [SI+2]              ; Y actual
    CMP AL, 5
    JLE DeactivateBullet
    
    SUB AL, 4                   ; Velocidad de disparo
    MOV [SI+2], AL
    
    ; Dibujar disparo
    XOR BH, BH
    MOV BL, [SI+1]              ; X
    XOR CH, CH
    MOV CL, AL                  ; Y
    
    PUSH AX
    MOV AL, BULLET_COLOR
    MOV DL, 2
    MOV DH, 4
    CALL DrawBox
    POP AX
    
    JMP NextBullet
    
DeactivateBullet:
    MOV BYTE PTR [SI], 0        ; Desactivar
    
NextBullet:
    ADD SI, 3
    LOOP UpdateBulletLoop
    
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
UpdateBullets ENDP

END