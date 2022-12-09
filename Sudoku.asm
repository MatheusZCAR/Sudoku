.MODEL SMALL

p_linha  MACRO 
mov ah,02
mov dl,10
int 21H
ENDM

pushreg  MACRO 
push ax
push bx
push dx
push si   
ENDM 

popreg  MACRO 
pop si
pop dx
pop cX
pop bx
pop ax 
ENDM

apagatela MACRO
MOV AH,0h
MOV AL,3h
INT 10H
XOR AX,AX
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
ENDM

.STACK 1000

.DATA

linha EQU 9
coluna EQU 9

matrizp1 DB 9 DUP(?)
         DB 9 DUP(?)
         DB 9 DUP(?)
         DB 9 DUP(?)
         DB 9 DUP(?)
         DB 9 DUP(?)
         DB 9 DUP(?)
         DB 9 DUP(?)
         DB 9 DUP(?)


matrizu1 DB 35h,33h,'X','X',37h,'X','X','X','X'
         DB 36h,'X','X',31h,39h,35h,'X','X','X'
         DB 'X',39h,38h,'X','X','X','X',36h,'X'
         DB 38h,'X','X','X',36h,'X','X','X',33h
         DB 34h,'X','X',38h,'X',33h,'X','X',31h
         DB 37h,'X','X','X',32h,'X','X','X',36h
         DB 'X',36h,'X','X','X','X',32h,38h,'X'
         DB 'X','X','X',34h,31h,39h,'X','X',35h
         DB 'X','X','X','X',38h,'X','X',37h,39h

matrizresp1 DB 35h,33h,34h,36h,37h,38h,39h,31h,32h
            DB 36h,37h,32h,31h,39h,35h,33h,34h,38h
            DB 31h,39h,38h,33h,34h,32h,35h,36h,37h
            DB 38h,35h,39h,37h,36h,31h,34h,32h,33h
            DB 34h,32h,36h,38h,35h,33h,37h,39h,31h
            DB 37h,31h,33h,39h,32h,34h,38h,35h,36h
            DB 39h,36h,31h,35h,33h,37h,32h,38h,34h
            DB 32h,38h,37h,34h,31h,39h,36h,33h,35h
            DB 33h,34h,35h,32h,38h,36h,31h,37h,39h

matrizp2 DB 9 DUP(?)
         DB 9 DUP(?)
         DB 9 DUP(?)
         DB 9 DUP(?)
         DB 9 DUP(?)
         DB 9 DUP(?)
         DB 9 DUP(?)
         DB 9 DUP(?)
         DB 9 DUP(?)

matrizu2 DB 'X','X','X',38h,'X','X','X',33h,32h
         DB 'X',38H,31h,33h,37h,'X','X','X','X'
         DB 36h,'X',33h,'X','X','X',31h,'X',38h
         DB 35h,39h,'X',34h,'X','X',33h,38h,'X'
         DB 'X','X',36h,35h,'X','X','X','X','X'
         DB 37h,'X',38h,'X',32h,'X','X','X',35h
         DB 'X','X','X','X',35h,34h,32h,'X','X'
         DB 'X','X','X','X','X','X',35h,'X','X'
         DB 34h,32h,35h,'X','X','X',38h,31h,37h

matrizresp2 DB 39h,37h,34h,38h,31h,35h,36h,33h,32h
            DB 32h,38H,31h,33h,37h,36h,39h,35h,34h
            DB 36h,35h,33h,32h,34h,39h,31h,37h,38h
            DB 35h,39h,32h,34h,36h,37h,33h,38h,31h
            DB 31h,34h,36h,35h,33h,38h,37h,32h,39h
            DB 37h,33h,38h,39h,32h,31h,34h,36h,35h
            DB 38h,36h,37h,31h,35h,34h,32h,39h,33h
            DB 33h,31h,39h,37h,38h,32h,35h,34h,36h
            DB 34h,32h,35h,36h,39h,33h,38h,31h,37h

bemvindo DB 30 DUP(32),201,20 DUP(205),187,10,30 DUP(32),186,'Bem-vindo ao Sudoku!',186,10,30 DUP(32),200,20 DUP(205),188,'$'
consiste DB 10,17 DUP(32),201,44 DUP(205),187,10,17 DUP(32),186,'O jogo consiste em um grande quadrado 9 x 9,',186,10,17 DUP(32),186,'com nove quadrados 3 x 3 em seu interior',4 DUP(32),186,10,17 DUP(32),200,44 DUP(205),188,'$'
objetivo DB 10,17 DUP(32),201,44 DUP(205),187,10,17 DUP(32),186,'Neste jogo, o jogador deve completar todos',2 DUP (32),186,10,17 DUP(32),186,'os "X" utilizando numeros de 1 a 9.',9 DUP(32),186,10,17 DUP(32),200,44 DUP(205),188,'$'
regras DB 10,17 DUP(32),201,44 DUP(205),187,10,17 DUP(32),186,'Nao podem haver numeros repetidos nas linhas',186,10,17 DUP(32),186,'verticais e horizontais, representadas por',2 DUP(32),186,10,17 DUP(32),186,'coordenadas de "a" ate "i".',17 DUP(32),186,10,17 DUP(32),200,44 DUP(205),188,'$'
regras2 DB 10,17 DUP(32),201,44 DUP(205),187,10,17 DUP(32),186,'Tambem nao sao permitidos numeros repetidos',32,186,10,17 DUP(32),186,'nos quadrados 3 x 3 delimitados pelas linhas',186,10,17 DUP(32),186,'internas',36 DUP (32),186,10,17 DUP(32),200,44 DUP(205),188,'$'
jogos DB 10,3 DUP(32),201,73 DUP(205),187,10,3 DUP(32),186,'Escolha o Sudoku que deseja resolver pressionando em seu teclado',9 DUP(32),186,10,3 DUP(32),186,'-> 1 ou -> 2',61 DUP(32),186,10,3 DUP(32),200,73 DUP(205),188,'$'


.CODE
    MAIN PROC
        MOV AX,@DATA
        MOV DS,AX
        ;MOV ES,AX
        XOR AX,AX

    INVALIDO:
        apagatela

        CALL MENU_IMP

        limpareg

        MOV ah,01h
        INT 21h

        SUB AL,30h

        CMP AL,1
        JL INVALIDO
        CMP AL,2
        JG INVALIDO

        CMP AL,1
        JE JOGOI

        CMP AL,2
        JE JOGOII

    
    JOGOI:
        apagatela
        LEA bx,matrizu1
        CALL IMPRIME_SUDOKU

        JMP FIM

    JOGOII:
        apagatela
        LEA bx,matrizu2
        CALL IMPRIME_SUDOKU
    
    FIM:
    MOV AH,4CH
    INT 21H
    MAIN ENDP



    IMPRIME_SUDOKU PROC
        ;pushreg 
        mov ah,02
        mov cx,linha

    outer:
        mov di,coluna
        xor si,si
    inner:
        mov dl,[bx][si]
        int 21H
        inc si
        dec DI
        jnz inner
        P_LINHA
        add bx,coluna
        loop outer
        ;popreg
        RET
    IMPRIME_SUDOKU ENDP

    MENU_IMP PROC
    MOV ah,09h
    LEA dx,bemvindo
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
    RET
    MENU_IMP ENDP

END MAIN
