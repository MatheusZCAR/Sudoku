TITLE NOME: JEAN OKABE REZENDE PITON | RA: 22013310 ||| NOME: MATHEUS ZANON CARITÁ | RA: 22014203

.MODEL SMALL

p_linha  MACRO 
    mov ah,02
    mov dl,10
    int 21H
ENDM

pushreg  MACRO 
    push si
    push dx
    push cx
    push bx
    push ax   
ENDM 

popreg  MACRO 
    pop si
    pop dx
    pop cx
    pop bx
    pop ax 
ENDM

apagatela MACRO
    MOV AH,0h
    MOV AL,3h
    INT 10H
    ;XOR AX,AX
    MOV AH,09
    MOV AL,20H
    MOV BH,00
    MOV BL,2FH
    MOV CX,800H
    INT 10H
ENDM

limpareg MACRO
    XOR AX,AX
    XOR BX,BX
    XOR CX,CX
    XOR DX,DX
    XOR SI,SI
ENDM

space MACRO 
    MOV AH, 02
    MOV DL, 32
    INT 21H    
ENDM

.DATA
bemvindo DB 30 DUP(32),201,20 DUP(205),187,10,30 DUP(32),186,'Bem-vindo ao Sudoku!',186,10,30 DUP(32),200,20 DUP(205),188,'$'
consiste DB 10,17 DUP(32),201,44 DUP(205),187,10,17 DUP(32),186,'O jogo consiste em um grande quadrado 9 x 9,',186,10,17 DUP(32),186,'com nove quadrados 3 x 3 em seu interior',4 DUP(32),186,10,17 DUP(32),200,44 DUP(205),188,'$'
objetivo DB 10,17 DUP(32),201,44 DUP(205),187,10,17 DUP(32),186,'Neste jogo, o jogador deve completar todos',2 DUP (32),186,10,17 DUP(32),186,'os "X" utilizando numeros de 1 a 9.',9 DUP(32),186,10,17 DUP(32),200,44 DUP(205),188,'$'
regras DB 10,17 DUP(32),201,44 DUP(205),187,10,17 DUP(32),186,'Nao podem haver numeros repetidos nas linhas',186,10,17 DUP(32),186,'verticais e horizontais, representadas por',2 DUP(32),186,10,17 DUP(32),186,'coordenadas de "a" ate "i".',17 DUP(32),186,10,17 DUP(32),200,44 DUP(205),188,'$'
regras2 DB 10,17 DUP(32),201,44 DUP(205),187,10,17 DUP(32),186,'Tambem nao sao permitidos numeros repetidos',32,186,10,17 DUP(32),186,'nos quadrados 3 x 3 delimitados pelas linhas',186,10,17 DUP(32),186,'internas',36 DUP (32),186,10,17 DUP(32),200,44 DUP(205),188,'$'
jogos DB 10,3 DUP(32),201,73 DUP(205),187,10,3 DUP(32),186,'Escolha o Sudoku que deseja resolver pressionando em seu teclado',9 DUP(32),186,10,3 DUP(32),186,'-> 1 ou -> 2',61 DUP(32),186,10,3 DUP(32),200,73 DUP(205),188,'$'
erronum DB 10,13, 'Numero de erros: ', '$'
limite DB '/3: ','$'

diglinha DB 10, 13, 'Digite a linha que deseja acessar: ','$'
digcoluna DB 10, 13, 'Digite a coluna que deseja acessar: ','$'
dignum DB 10, 13, 'Digite o numero (de 1 a 9): ','$'
erro DB 10, 13, 'Numero incorreto!', '$'

conta_acertos DB ?
conta_erros DB ?

linha EQU 9
coluna EQU 9


JOGO DB LINHA DUP (COLUNA DUP (?))
JOGO_RESPOSTA DB LINHA DUP (COLUNA DUP (?))

;matriz do jogo 1
MATRIZPRIMEIRA DB 5,3,?,  ?,7,?,  ?,?,?
               DB 6,?,?,  1,9,5,  ?,?,?
               DB ?,9,8,  ?,?,?,  ?,6,?
         
               DB 8,?,?,  ?,6,?,  ?,?,3
               DB 4,?,?,  8,?,3,  ?,?,1
               DB 7,?,?,  ?,2,?,  ?,?,6
         
               DB ?,6,?,  ?,?,?,  2,8,?
               DB ?,?,?,  4,1,9,  ?,?,5
               DB ?,?,?,  ?,8,?,  ?,7,9

;gabarito do jogo 1
MATRIZRESP_PR DB 5,3,4,  6,7,8,  9,1,2
              DB 6,7,2,  1,9,5,  3,4,8
              DB 1,9,8,  3,4,2,  5,6,7

              DB 8,5,9,  7,6,1,  4,2,3
              DB 4,2,6,  8,5,3,  7,9,1
              DB 7,1,3,  9,2,4,  8,5,6

              DB 9,6,1,  5,3,7,  2,8,4
              DB 2,8,7,  4,1,9,  6,3,5
              DB 3,4,5,  2,8,6,  1,7,9

;matriz do jogo 2
MATRIZSEGUNDA DB ?,?,?,  8,?,?,  ?,3,2
              DB ?,8,1,  3,7,?,  ?,?,?
              DB 6,?,3,  ?,?,?,  1,?,8

              DB 5,9,?,  4,?,?,  3,8,?
              DB ?,?,6,  5,?,?,  ?,?,?
              DB 7,?,8,  ?,2,?,  ?,?,5

              DB ?,?,?,  ?,5,4,  2,?,?
              DB ?,?,?,  ?,?,?,  5,?,?
              DB 4,2,5,  ?,?,?,  8,1,7

;gabarito do jogo 2
MATRIZRESP_SEG DB 9,7,4,  8,1,5,  6,3,2
               DB 2,8,1,  3,7,6,  9,5,4
               DB 6,5,3,  2,4,9,  1,7,8

               DB 5,9,2,  4,6,7,  3,8,1
               DB 1,4,6,  5,3,8,  7,2,9
               DB 7,3,8,  9,2,1,  4,6,5

               DB 8,6,7,  1,5,4,  2,9,3
               DB 3,1,9,  7,8,2,  5,4,6
               DB 4,2,5,  6,9,3,  8,1,7

.CODE
    MAIN PROC
        MOV AX,@DATA
        MOV DS,AX
        MOV ES,AX
        

    VOLTAINICIO:
        apagatela
        MOV conta_acertos, 0
        MOV conta_erros, 0

        CALL MENU_IMP
        CMP AL,1
        JE JOGOI

        CMP AL,2
        JE JOGOII

        CMP AL,3
        JE FIM

        CMP AL,1
        JL VOLTAINICIO
        CMP AL,3
        JG VOLTAINICIO
    
    JOGOI:
        apagatela
        LEA BX,MATRIZPRIMEIRA
        CALL CONTADOR_ERROS
        XOR BX,BX
        LEA BX,MATRIZPRIMEIRA
        CALL IMPRIME_SUDOKU
        CALL VERIFICA_RESPI
        
        CALL JOGAR_NOVAMENTE
        JL JOGOI
        JMP FIM

    JOGOII:
        apagatela
        limpareg
        LEA bx,MATRIZSEGUNDA
        CALL CONTADOR_ERROS
        XOR BX,BX
        LEA BX,MATRIZSEGUNDA
        CALL IMPRIME_SUDOKU
        CALL VERIFICA_RESPII
        
        CALL JOGAR_NOVAMENTE
        JL JOGOII
        JMP FIM
    
    FIM:
        MOV AH,4CH
        INT 21H
        MAIN ENDP



IMPRIME_SUDOKU PROC
    pushreg

    MOV AH,02
    MOV CX,linha
    

 OUTER:
    PUSH AX
    PUSH DX
    space
    POP DX
    POP AX

    MOV DI,coluna
    XOR SI,SI
 INNER:
    MOV DL,[BX][SI]
    OR DL,30H
    INT 21H
    INC SI
    DEC DI

    PUSH AX
    PUSH DX
    space
    POP DX
    POP AX

    JNZ INNER
    p_linha
    ADD BX,coluna
    LOOP OUTER
    popreg
    RET
IMPRIME_SUDOKU ENDP

        MENU_IMP PROC
        LEA dx,bemvindo
        MOV ah,09h
        INT 21h

        LEA dx,consiste
        INT 21h

        LEA dx,objetivo
        INT 21h

        LEA dx,regras
        INT 21h

        LEA dx,regras2
        INT 21h

        LEA dx,jogos
        INT 21h

        MOV ah,01h
        INT 21H

        SUB AL,30h
        CMP AL,2

        RET
        
    MENU_IMP ENDP

    CONTADOR_ERROS PROC
        pushreg
        limpareg
        LEA DX, erronum
        MOV AH,09H
        INT 21H

        MOV DL, conta_erros
        ADD DL,30H
        MOV AH,02H
        INT 21H

        LEA DX, limite
        MOV AH,09H
        INT 21H
        
        p_linha
        popreg
        RET
    CONTADOR_ERROS ENDP

    VERIFICA_RESPI PROC
        pushreg
        limpareg

;entrada da linha
        LEA DX, diglinha
        MOV AH,09H
        INT 21H

        MOV AH,01H
        INT 21H
        SUB AL,30H

        MOV CX, 9
        MUL CX
        XOR AH,AH

        MOV BX,AX
        SUB BX,9

;entrada da coluna
        LEA DX, digcoluna
        MOV AH,09H
        INT 21H

        MOV AH,01H
        INT 21H
        SUB AL,31H    

        XOR AH,AH
        MOV SI,AX

        LEA DX, dignum
        MOV AH,09H
        INT 21H

        MOV AH,01H
        INT 21H
        SUB AL,30H

        CMP AL, MATRIZRESP_PR[BX][SI]

        JE ACERTOSI
        ;contador de erros
        PUSH DX
        XOR DL,DL
        MOV DL, conta_erros
        INC DL
        MOV conta_erros, DL
        POP DX

        JMP SAIRI
        XOR AX,AX

    ACERTOSI:
        ADD AL,30H
        MOV MATRIZPRIMEIRA[BX][SI],AL

        ;contador de erros
        PUSH DX
        XOR DL,DL
        MOV DL, conta_acertos
        INC DL
        MOV conta_acertos,DL
        POP DX
        JMP SAIRI

    SAIRI:
        popreg
        
        RET
    VERIFICA_RESPI ENDP

    VERIFICA_RESPII PROC
        pushreg
        limpareg

;entrada da linha
        LEA DX, diglinha
        MOV AH,09H
        INT 21H

        MOV AH,01H
        INT 21H
        SUB AL,30H

        MOV CX, 9
        MUL CX
        XOR AH,AH

        MOV BX,AX
        SUB BX,9

;entrada da coluna
        LEA DX, digcoluna
        MOV AH,09H
        INT 21H

        MOV AH,01H
        INT 21H
        SUB AL,31H    

        XOR AH,AH
        MOV SI,AX

        LEA DX, dignum
        MOV AH,09H
        INT 21H

        MOV AH,01H
        INT 21H
        SUB AL,30H

        CMP AL, MATRIZRESP_SEG[BX][SI]

        JE ACERTOSII
        ;contador de erros
        PUSH DX
        XOR DL,DL
        MOV DL, conta_erros
        INC DL
        MOV conta_erros, DL
        POP DX

        JMP SAIRII
        XOR AX,AX

    ACERTOSII:
        ADD AL,30H
        MOV MATRIZSEGUNDA[BX][SI],AL

        ;contador de erros
        PUSH DX
        XOR DL,DL
        MOV DL, conta_acertos
        INC DL
        MOV conta_acertos,DL
        POP DX
        JMP SAIRII

    SAIRII:
        popreg
        
        RET
    VERIFICA_RESPII ENDP
        
    JOGAR_NOVAMENTE PROC
        pushreg

        MOV DL, conta_erros
        CMP DL,3
        popreg
        
        RET
    JOGAR_NOVAMENTE ENDP

END MAIN
