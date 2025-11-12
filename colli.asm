;==============================================================================
; SPACE INVADERS - COLLISION.ASM
; Detección de colisiones y actualización de puntaje
;==============================================================================

.MODEL SMALL

;------------------------------------------------------------------------------
; DECLARACIONES EXTERNAS
;------------------------------------------------------------------------------
EXTRN bullets:BYTE, enemies:BYTE
EXTRN enemies_left:WORD

;------------------------------------------------------------------------------
; CONSTANTES
;------------------------------------------------------------------------------
MAX_BULLETS EQU 5
ENEMY_COUNT EQU 24              ; 3 filas x 8 columnas
ENEMY_WIDTH EQU 10
ENEMY_HEIGHT EQU 8
BULLET_WIDTH EQU 2
BULLET_HEIGHT EQU 4

;------------------------------------------------------------------------------
; SEGMENTO DE DATOS
;------------------------------------------------------------------------------
.DATA
    score DW 0                  ; Puntaje del jugador
    
PUBLIC score

;------------------------------------------------------------------------------
; SEGMENTO DE CÓDIGO
;------------------------------------------------------------------------------
.CODE

;------------------------------------------------------------------------------
; CheckCollisions: Detecta colisiones entre disparos y enemigos
;------------------------------------------------------------------------------
PUBLIC CheckCollisions
CheckCollisions PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
    
    ; Iterar sobre todos los disparos
    LEA SI, bullets
    MOV CX, MAX_BULLETS
    
CheckBulletLoop:
    ; Verificar si el disparo está activo
    CMP BYTE PTR [SI], 0
    JE NextBullet
    
    ; Obtener posición del disparo
    MOV BL, [SI+1]              ; X del disparo
    MOV BH, [SI+2]              ; Y del disparo
    
    ; Iterar sobre todos los enemigos
    PUSH SI
    PUSH CX
    
    LEA DI, enemies
    MOV CX, ENEMY_COUNT
    
CheckEnemyLoop:
    ; Verificar si el enemigo está activo
    CMP BYTE PTR [DI], 0
    JE NextEnemy
    
    ; Obtener posición del enemigo
    MOV DL, [DI+1]              ; X del enemigo
    MOV DH, [DI+2]              ; Y del enemigo
    
    ; Verificar colisión en X
    ; Disparo.X >= Enemigo.X && Disparo.X <= Enemigo.X + ancho
    CMP BL, DL
    JL NextEnemy
    
    MOV AL, DL
    ADD AL, ENEMY_WIDTH
    CMP BL, AL
    JG NextEnemy
    
    ; Verificar colisión en Y
    ; Disparo.Y >= Enemigo.Y && Disparo.Y <= Enemigo.Y + alto
    CMP BH, DH
    JL NextEnemy
    
    MOV AL, DH
    ADD AL, ENEMY_HEIGHT
    CMP BH, AL
    JG NextEnemy
    
    ; ¡Colisión detectada!
    ; Desactivar enemigo
    MOV BYTE PTR [DI], 0
    
    ; Desactivar disparo
    POP CX
    POP SI
    MOV BYTE PTR [SI], 0
    
    ; Actualizar puntaje y contador
    ADD score, 10
    DEC enemies_left
    
    ; Salir de los loops
    JMP CollisionFound
    
NextEnemy:
    ADD DI, 3
    LOOP CheckEnemyLoop
    
    POP CX
    POP SI
    
NextBullet:
    ADD SI, 3
    LOOP CheckBulletLoop
    
CollisionFound:
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
CheckCollisions ENDP

;------------------------------------------------------------------------------
; GetScore: Retorna el puntaje actual
; Salida: AX = score
;------------------------------------------------------------------------------
PUBLIC GetScore
GetScore PROC
    MOV AX, score
    RET
GetScore ENDP

;------------------------------------------------------------------------------
; ResetScore: Reinicia el puntaje
;------------------------------------------------------------------------------
PUBLIC ResetScore
ResetScore PROC
    MOV score, 0
    RET
ResetScore ENDP

END