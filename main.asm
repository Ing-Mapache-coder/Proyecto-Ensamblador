;==============================================================================
; SPACE INVADERS - MAIN.ASM
; Módulo principal: inicialización, bucle de juego y control general
;==============================================================================

.MODEL SMALL
.STACK 100h

;------------------------------------------------------------------------------
; DECLARACIONES EXTERNAS
;------------------------------------------------------------------------------
EXTRN InitGraphics:PROC, ClearScreen:PROC, SetPixel:PROC
EXTRN InitPlayer:PROC, DrawPlayer:PROC, MovePlayerLeft:PROC
EXTRN MovePlayerRight:PROC, ShootPlayer:PROC, UpdateBullets:PROC
EXTRN InitEnemies:PROC, DrawEnemies:PROC, UpdateEnemies:PROC
EXTRN CheckCollisions:PROC, GetScore:PROC
EXTRN Delay:PROC, CoordToOffset:PROC

;------------------------------------------------------------------------------
; SEGMENTO DE DATOS
;------------------------------------------------------------------------------
.DATA
    game_over DB 0              ; 0 = jugando, 1 = fin del juego
    enemies_left DW 0           ; Enemigos restantes
    player_alive DB 1           ; 1 = vivo, 0 = muerto
    
    msg_victory DB 'VICTORIA!$'
    msg_gameover DB 'GAME OVER!$'
    
PUBLIC game_over, enemies_left, player_alive

;------------------------------------------------------------------------------
; SEGMENTO DE CÓDIGO
;------------------------------------------------------------------------------
.CODE
START:
    MOV AX, @DATA
    MOV DS, AX
    
    ; Inicializar modo gráfico VGA 13h
    CALL InitGraphics
    
    ; Inicializar jugador
    CALL InitPlayer
    
    ; Inicializar enemigos
    CALL InitEnemies
    
    ; Bucle principal del juego
GameLoop:
    ; Verificar si el juego terminó
    CMP game_over, 1
    JE EndGame
    
    ; Limpiar pantalla
    CALL ClearScreen
    
    ; Leer entrada del teclado
    CALL ReadInput
    
    ; Actualizar disparos del jugador
    CALL UpdateBullets
    
    ; Actualizar enemigos
    CALL UpdateEnemies
    
    ; Detectar colisiones
    CALL CheckCollisions
    
    ; Dibujar jugador
    CALL DrawPlayer
    
    ; Dibujar enemigos
    CALL DrawEnemies
    
    ; Pequeño delay para controlar velocidad
    MOV CX, 1
    CALL Delay
    
    JMP GameLoop

;------------------------------------------------------------------------------
; EndGame: Muestra mensaje final y restaura modo texto
;------------------------------------------------------------------------------
EndGame:
    ; Pequeño delay antes de mostrar mensaje
    MOV CX, 10
    CALL Delay
    
    ; Restaurar modo texto
    MOV AH, 0
    MOV AL, 3
    INT 10h
    
    ; Mostrar mensaje según resultado
    CMP player_alive, 0
    JE ShowGameOver
    
ShowVictory:
    LEA DX, msg_victory
    JMP ShowMessage
    
ShowGameOver:
    LEA DX, msg_gameover
    
ShowMessage:
    MOV AH, 9
    INT 21h
    
    ; Esperar tecla
    MOV AH, 0
    INT 16h
    
    ; Terminar programa
    MOV AH, 4Ch
    INT 21h

;------------------------------------------------------------------------------
; ReadInput: Lee el teclado sin bloquear
;------------------------------------------------------------------------------
ReadInput PROC
    ; Verificar si hay tecla disponible
    MOV AH, 1
    INT 16h
    JZ NoKey                    ; Si ZF=1, no hay tecla
    
    ; Leer tecla sin esperar
    MOV AH, 0
    INT 16h
    
    ; Verificar teclas especiales (flechas)
    CMP AH, 4Bh                 ; Flecha izquierda
    JE PressedLeft
    
    CMP AH, 4Dh                 ; Flecha derecha
    JE PressedRight
    
    ; Verificar barra espaciadora
    CMP AL, 32                  ; Código ASCII espacio
    JE PressedSpace
    
    ; Verificar ESC para salir
    CMP AL, 27
    JE PressedEsc
    
    JMP NoKey

PressedLeft:
    CALL MovePlayerLeft
    JMP NoKey

PressedRight:
    CALL MovePlayerRight
    JMP NoKey

PressedSpace:
    CALL ShootPlayer
    JMP NoKey

PressedEsc:
    MOV game_over, 1
    MOV player_alive, 0

NoKey:
    RET
ReadInput ENDP

END START