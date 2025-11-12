;==============================================================================
; SPACE INVADERS - ENEMIES.ASM
; Control de enemigos: generación, movimiento y renderizado
;==============================================================================

.MODEL SMALL

;------------------------------------------------------------------------------
; DECLARACIONES EXTERNAS
;------------------------------------------------------------------------------
EXTRN DrawSprite:PROC, DrawBox:PROC
EXTRN game_over:BYTE, enemies_left:WORD, player_alive:BYTE

;------------------------------------------------------------------------------
; CONSTANTES
;------------------------------------------------------------------------------
ENEMY_COLOR EQU 4               ; Rojo
ENEMY_ROWS EQU 3                ; Filas de enemigos
ENEMY_COLS EQU 8                ; Columnas de enemigos
ENEMY_COUNT EQU ENEMY_ROWS * ENEMY_COLS
ENEMY_WIDTH EQU 10
ENEMY_HEIGHT EQU 8
ENEMY_SPACING_X EQU 15
ENEMY_SPACING_Y EQU 15

;------------------------------------------------------------------------------
; SEGMENTO DE DATOS
;------------------------------------------------------------------------------
.DATA
    ; Array de enemigos [activo, x, y]
    enemies DB ENEMY_COUNT * 3 DUP(0)
    
    enemy_direction DB 1        ; 1 = derecha, 0 = izquierda
    enemy_speed DB 2            ; Velocidad horizontal
    move_counter DB 0           ; Contador para controlar velocidad
    
PUBLIC enemies, enemy_direction

;------------------------------------------------------------------------------
; SEGMENTO DE CÓDIGO
;------------------------------------------------------------------------------
.CODE

;------------------------------------------------------------------------------
; InitEnemies: Inicializa la formación de enemigos
;------------------------------------------------------------------------------
PUBLIC InitEnemies
InitEnemies PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    
    LEA SI, enemies
    MOV enemies_left, ENEMY_COUNT
    
    MOV DH, 0                   ; Fila actual
    
InitEnemyRows:
    CMP DH, ENEMY_ROWS
    JGE InitEnemiesEnd
    
    MOV DL, 0                   ; Columna actual
    
InitEnemyCols:
    CMP DL, ENEMY_COLS
    JGE NextRow
    
    ; Activar enemigo
    MOV BYTE PTR [SI], 1
    
    ; Calcular posición X
    MOV AL, DL
    MOV BL, ENEMY_SPACING_X
    MUL BL
    ADD AL, 40                  ; Margen izquierdo
    MOV [SI+1], AL
    
    ; Calcular posición Y
    MOV AL, DH
    MOV BL, ENEMY_SPACING_Y
    MUL BL
    ADD AL, 30                  ; Margen superior
    MOV [SI+2], AL
    
    ADD SI, 3
    INC DL
    JMP InitEnemyCols
    
NextRow:
    INC DH
    JMP InitEnemyRows
    
InitEnemiesEnd:
    MOV enemy_direction, 1
    MOV move_counter, 0
    
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
InitEnemies ENDP

;------------------------------------------------------------------------------
; DrawEnemies: Dibuja todos los enemigos activos
;------------------------------------------------------------------------------
PUBLIC DrawEnemies
DrawEnemies PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    
    LEA SI, enemies
    MOV CX, ENEMY_COUNT
    
DrawEnemyLoop:
    CMP BYTE PTR [SI], 0        ; ¿Está activo?
    JE NextEnemy
    
    ; Dibujar enemigo
    XOR BH, BH
    MOV BL, [SI+1]              ; X
    XOR CH, CH
    MOV CL, [SI+2]              ; Y
    MOV AL, ENEMY_COLOR
    MOV DL, ENEMY_WIDTH
    MOV DH, ENEMY_HEIGHT
    CALL DrawBox
    
NextEnemy:
    ADD SI, 3
    LOOP DrawEnemyLoop
    
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
DrawEnemies ENDP

;------------------------------------------------------------------------------
; UpdateEnemies: Actualiza posiciones de enemigos
;------------------------------------------------------------------------------
PUBLIC UpdateEnemies
UpdateEnemies PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH SI
    
    ; Control de velocidad
    INC move_counter
    CMP move_counter, 3
    JL UE_End
    MOV move_counter, 0
    
    ; Verificar si hay enemigos vivos
    CMP enemies_left, 0
    JNE UE_Continue
    JMP UE_Won
    
UE_Continue:
    LEA SI, enemies
    MOV CX, ENEMY_COUNT
    MOV BL, 0                   ; Flag: necesita cambiar dirección
    
UE_CheckBounds:
    CMP BYTE PTR [SI], 0
    JE UE_CheckNext
    
    MOV AL, [SI+1]              ; X actual
    
    CMP enemy_direction, 1
    JE UE_CheckRight
    
    CMP AL, 5
    JLE UE_NeedChange
    JMP UE_CheckNext
    
UE_CheckRight:
    CMP AL, 240
    JL UE_CheckNext
    
UE_NeedChange:
    MOV BL, 1
    
UE_CheckNext:
    ADD SI, 3
    LOOP UE_CheckBounds
    
    ; Si se necesita cambiar dirección
    CMP BL, 1
    JNE UE_MoveHor
    
    ; Cambiar dirección y bajar
    XOR enemy_direction, 1
    CALL MoveEnemiesDown
    JMP UE_End
    
UE_MoveHor:
    CALL MoveEnemiesHorizontal
    JMP UE_End
    
UE_Won:
    MOV game_over, 1
    MOV player_alive, 1
    
UE_End:
    POP SI
    POP CX
    POP BX
    POP AX
    RET
UpdateEnemies ENDP

;------------------------------------------------------------------------------
; MoveEnemiesDown: Mueve enemigos hacia abajo
;------------------------------------------------------------------------------
MoveEnemiesDown PROC
    PUSH AX
    PUSH CX
    PUSH SI
    
    LEA SI, enemies
    MOV CX, ENEMY_COUNT
    
MED_Loop:
    CMP BYTE PTR [SI], 0
    JE MED_Next
    
    MOV AL, [SI+2]              ; Y actual
    ADD AL, 10                  ; Bajar
    MOV [SI+2], AL
    
    ; Verificar si llegó al fondo
    CMP AL, 170
    JL MED_Next
    
    ; Game Over
    MOV game_over, 1
    MOV player_alive, 0
    
MED_Next:
    ADD SI, 3
    LOOP MED_Loop
    
    POP SI
    POP CX
    POP AX
    RET
MoveEnemiesDown ENDP

;------------------------------------------------------------------------------
; MoveEnemiesHorizontal: Mueve enemigos horizontalmente
;------------------------------------------------------------------------------
MoveEnemiesHorizontal PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH SI
    
    LEA SI, enemies
    MOV CX, ENEMY_COUNT
    
MEH_Loop:
    CMP BYTE PTR [SI], 0
    JE MEH_Next
    
    MOV AL, [SI+1]              ; X actual
    MOV BL, enemy_speed
    
    CMP enemy_direction, 1
    JE MEH_Right
    
    SUB AL, BL
    JMP MEH_Update
    
MEH_Right:
    ADD AL, BL
    
MEH_Update:
    MOV [SI+1], AL
    
MEH_Next:
    ADD SI, 3
    LOOP MEH_Loop
    
    POP SI
    POP CX
    POP BX
    POP AX
    RET
MoveEnemiesHorizontal ENDP

END