TITLE NOME: JEAN OKABE REZENDE PITON | RA: 22013310 ||| NOME: MATHEUS ZANON CARITÁ | RA: 22014203

.MODEL SMALL

p_linha  MACRO    ;macro que pula linha
    MOV AH,02
    MOV DL,10
    INT 21H
ENDM

pushreg  MACRO    ;macro que faz o push em todos os registradores importantes
    PUSH SI
    PUSH DX
    PUSH CX
    PUSH BX
    PUSH AX   
ENDM 

popreg  MACRO   ;macro que faz o pop em todos os registradores importantes
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX 
ENDM

apagatela MACRO ;macro que apaga a tela e define a cor de fundo como verde
    MOV AH,0h
    MOV AL,3h
    INT 10H
    MOV AH,09
    MOV AL,20H
    MOV BH,00
    MOV BL,2FH
    MOV CX,800H
    INT 10H
ENDM

limpareg MACRO  ;macro que limpa os registradores importantes
    XOR AX,AX
    XOR BX,BX
    XOR CX,CX
    XOR DX,DX
    XOR SI,SI
ENDM

space MACRO    ;macro que funciona como um espaço (spacebar)
    MOV AH, 02
    MOV DL, 32
    INT 21H    
ENDM

.DATA
;textos para o menu inicial
bemvindo DB 30 DUP(32),201,20 DUP(205),187,10,30 DUP(32),186,'Bem-vindo ao Sudoku!',186,10,30 DUP(32),200,20 DUP(205),188,'$'
consiste DB 10,17 DUP(32),201,44 DUP(205),187,10,17 DUP(32),186,'O jogo consiste em um grande quadrado 9 x 9,',186,10,17 DUP(32),186,'com nove quadrados 3 x 3 em seu interior',4 DUP(32),186,10,17 DUP(32),200,44 DUP(205),188,'$'
objetivo DB 10,17 DUP(32),201,44 DUP(205),187,10,17 DUP(32),186,'Neste jogo, o jogador deve completar todos',2 DUP (32),186,10,17 DUP(32),186,'os "X" utilizando numeros de 1 a 9.',9 DUP(32),186,10,17 DUP(32),200,44 DUP(205),188,'$'
regras DB 10,17 DUP(32),201,44 DUP(205),187,10,17 DUP(32),186,'Nao podem haver numeros repetidos nas linhas',186,10,17 DUP(32),186,'verticais e horizontais, representadas por',2 DUP(32),186,10,17 DUP(32),186,'coordenadas de "a" ate "i".',17 DUP(32),186,10,17 DUP(32),200,44 DUP(205),188,'$'
regras2 DB 10,17 DUP(32),201,44 DUP(205),187,10,17 DUP(32),186,'Tambem nao sao permitidos numeros repetidos',32,186,10,17 DUP(32),186,'nos quadrados 3 x 3 delimitados pelas linhas',186,10,17 DUP(32),186,'internas',36 DUP (32),186,10,17 DUP(32),200,44 DUP(205),188,'$'
jogos DB 10,3 DUP(32),201,73 DUP(205),187,10,3 DUP(32),186,'Escolha o Sudoku que deseja resolver pressionando em seu teclado',9 DUP(32),186,10,3 DUP(32),186,'-> 1  -> 2  -> 3 Sair',52 DUP(32),186,10,3 DUP(32),200,73 DUP(205),188,'$'
;fim dos textos para o menu inicial

;texto para contador de erros
erronum DB 10,13, 'Numero de erros: ', '$'
limite DB 179,'3','$'
;fim do texto para contador de erros

;texto para instruir a escolha da linha, coluna e numero desejado
diglinha DB 10, 13, 'Digite a linha que deseja acessar: ','$'
digcoluna DB 10, 13, 'Digite a coluna que deseja acessar: ','$'
dignum DB 10, 13, 'Digite o numero (de 1 a 9): ','$'
;fim do texto para instruir a escolha da linha, coluna e numero desejado

;mensagem para quando o jogador perde e para quando ganha, respectivamente
perdeumsg DB 32 DUP(32),201,12 DUP(205),187,10,32 DUP(32),186,'Voce perdeu!',186,10,32 DUP(32),200,12 DUP(205),188,'$'
venceumsg DB 32 DUP(32),201,12 DUP(205),187,10,32 DUP(32),186,'Voce venceu!',186,10,32 DUP(32),200,12 DUP(205),188,'$'
;fim das mensagens para quando o jogador perde ou ganha

;variaveis para o contador de erros
conta_acertos DB ?
conta_erros DB ?

;variaveis de numero de linhas e colunas
linha EQU 9
coluna EQU 9

;matriz do jogo 1
MATRIZPRIMEIRA DB 5,3,'X',  'X',7,'X',  'X','X','X'
               DB 6,'X','X',  1,9,5,  'X','X','X'
               DB 'X',9,8,  'X','X','X',  'X',6,'X'
         
               DB 8,'X','X',  'X',6,'X',  'X','X',3
               DB 4,'X','X',  8,'X',3,  'X','X',1
               DB 7,'X','X',  'X',2,'X',  'X','X',6
         
               DB 'X',6,'X',  'X','X','X',  2,8,'X'
               DB 'X','X','X',  4,1,9,  'X','X',5
               DB 'X','X','X',  'X',8,'X',  'X',7,9

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
MATRIZSEGUNDA DB 'X','X','X',  8,'X','X',  'X',3,2
              DB 'X',8,1,  3,7,'X',  'X','X','X'
              DB 6,'X',3,  'X','X','X',  1,'X',8

              DB 5,9,'X',  4,'X','X',  3,8,'X'
              DB 'X','X',6,  5,'X','X',  'X','X','X'
              DB 7,'X',8,  'X',2,'X',  'X','X',5

              DB 'X','X','X',  'X',5,4,  2,'X','X'
              DB 'X','X','X',  'X','X','X',  5,'X','X'
              DB 4,2,5,  'X','X','X',  8,1,7

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
        MOV AX,@DATA   ;inicializa o data (DS e ES), manipulacao de matrizes
        MOV DS,AX       
        MOV ES,AX
        

    VOLTAINICIO:                ;volta para a tela inicial, caso o jogador digite uma opcao invalida
        apagatela               ;macro que muda a tela
        MOV conta_acertos, 0    ;zera o contador de acertos
        MOV conta_erros, 0      ;zer o contador de erros

        CALL MENU_IMP           ;chama o procedimento que imprime o menu
        CMP AL,1                ;compara o que o jogador digitou com as opcoes do menu
        JE JOGOI                ;se digitou 1, vai para o primeiro jogo

        CMP AL,2                ; se digitou 2, vai para o segundo jogo
        JE JOGOII

        CMP AL,3                ;se digitou 3, sai do jogo
        JE FIM

        CMP AL,1
        JL VOLTAINICIO          ;se valor digitado for menor que 1, volta para o inicio
        CMP AL,3                ;se valor digitado for maior que 3, volta para o inicio
        JG VOLTAINICIO
    
    JOGOI:
        apagatela               ;macro que muda a tela
        CALL CONTADOR_ERROS     ;chama o procedimento que conta os erros
        XOR BX,BX               ;zera o BX e evita transtornos na hora de imprimir
        LEA BX,MATRIZPRIMEIRA   ;le a matriz do jogo 1
        CALL IMPRIME_SUDOKU     ;procedimento que imprime a matriz do jogo
        CALL VERIFICA_RESPI     ;procedimento que verifica se o jogador acertou ou errou (jogo 1)
        
        CALL PERDEU_CONTADOR    ;procedimento que define os erros a somente 3, alem de atualizar o contador
        JE DERROTA              ;se os erros forem 3, vai para a tela de derrota

        CALL GANHOU_CONTADOR    ;procedimento que define os acertos maximos do jogo I
        JE VITORIA              ;se o numero de acertos for igual a quantidade de casas preenchidas corretamente, vai para a tela de vitoria

        JMP JOGOI               ;repete o jogo 1, caso o jogador nao tenha ganhado ou perdido

    JOGOII:
        apagatela               ;macro que muda a tela
        CALL CONTADOR_ERROS     ;chama o procedimento que conta os erros
        XOR BX,BX               ;zera o BX e evita transtornos na hora de imprimir
        LEA BX,MATRIZSEGUNDA    ;le a matriz do jogo 2
        CALL IMPRIME_SUDOKU     ;procedimento que imprime a matriz do jogo
        CALL VERIFICA_RESPII    ;procedimento que verifica se o jogador acertou ou errou (jogo2)
        
        CALL PERDEU_CONTADOR    ;procedimento que define os erros a somente 3, alem de atualizar o contador
        JE DERROTA              ;se os erros forem 3, vai para a tela de derrota

        CALL GANHOU_CONTADORII  ;procedimento que define os acertos maximos do jogo II
        JE VITORIA              ;se o numero de acertos for igual a quantidade de casas preenchidas corretamente, vai para a tela de vitoria

        JMP JOGOII              ;repete o jogo 2, caso o jogador nao tenha ganhado ou perdido
    
    DERROTA:
        CALL PERDEU_MSG         ;chama o procedimento que imprime a tela de derrota
        JMP VOLTAINICIO         ;volta para a tela inicial

    VITORIA:
        CALL VENCEU_MSG         ;chama o procedimento que imprime a tela de vitoria
        JMP VOLTAINICIO         ;volta para a tela inicial

    FIM:                        ;finaliza o jogo
        MOV AH,4CH
        INT 21H
        MAIN ENDP


IMPRIME_SUDOKU PROC
    pushreg                    ;salva os registradores

    MOV AH,02                  ;move 02 para ah (funcao de impressao que sera utilizada posteriormente)
    MOV CX,linha               ;define o contador de acordo com o numero de linhas da matriz do jogo
    

 OUTER:                        ;loop externo
    PUSH AX
    PUSH DX
    space                      ;macro que imprime um espaco
    POP DX
    POP AX

    MOV DI,coluna              ;define o contador de acordo com o numero de colunas da matriz do jogo
    XOR SI,SI                  ;limpa SI
 
 INNER:                        ;loop interno
    MOV DL,[BX][SI]            ;move o valor da matriz para DL
    OR DL,30H                  ;transforma o valor em ASCII
    INT 21H                    ;imprime o valor na tela (ah = 02)
    INC SI                     ;incrementa SI (para percorrer a matriz)
    DEC DI                     ;decrement DI  (para percorrer a matriz)

    PUSH AX
    PUSH DX
    space
    POP DX
    POP AX

    JNZ INNER                  ;se DI for diferente de zero, repete o loop interno
    p_linha                    ;macro que imprime uma quebra de linha
    ADD BX,coluna              ;adiciona o numero de colunas da matriz para bx  (para percorrer a matriz) 
    LOOP OUTER                 ;se CX for diferente de zero, repete o loop externo
    popreg                     ;resgata valores dos registradores
    RET                        ;retorna o procedimento a main
IMPRIME_SUDOKU ENDP            ;fim do procedimento

        MENU_IMP PROC          ;procedimento que imprime o menu, com mensagens
        LEA dx,bemvindo        ;de boas vindas, regras e etc.
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

        MOV ah,01h          ;le o valor digitado pelo usuario
        INT 21H

        SUB AL,30h          ;transforma o valor em ASCII
        CMP AL,2            ;compara o valor digitado com 2 (para saber qual jogo o usuario quer jogar)

        RET                 ;retorna o procedimento a main
        
    MENU_IMP ENDP           ;fim do procedimento

    CONTADOR_ERROS PROC     ;procedimento que conta os erros
        pushreg             ;salva os registradores
        limpareg            ;limpa os registradores
        LEA DX, erronum     ;le a mensagem de numero de erros
        MOV AH,09H          ;imprime a mensagem
        INT 21H

        MOV DL, conta_erros ;move o valor de conta_erros para DL
        ADD DL,30H          ;transforma o valor em ASCII
        MOV AH,02H          ;imprime o valor na tela
        INT 21H

        LEA DX, limite      ;le a mensagem de limite de erros (3)
        MOV AH,09H
        INT 21H
        
        p_linha             ;pula linha
        popreg              ;resgata valores dos registradores
        RET                 ;retorna o procedimento a main
    CONTADOR_ERROS ENDP     ;fim do procedimento

    VERIFICA_RESPI PROC     ;procedimento que verifica se o jogador acertou ou errou (jogo 1)
        pushreg             ;salva os registradores
        limpareg            ;limpa os registradores

;entrada da linha
        LEA DX, diglinha    ;le a mensagem de entrada da linha
        MOV AH,09H
        INT 21H

        MOV AH,01H          ;le o valor digitado pelo usuario (seleciona a linha)
        INT 21H
        SUB AL,30H          ;transforma o valor em digito

        MOV CX, 9           ;define o contador de acordo com o numero de linhas da matriz do jogo
        MUL CX              ;multiplica o valor digitado pelo usuario pelo numero de linhas da matriz
        XOR AH,AH           ;limpa AH

        MOV BX,AX           ;move o valor de AX para BX (representa as linhas)
        SUB BX,9            ;subtrai 9 do valor de BX

;entrada da coluna
        LEA DX, digcoluna   ;le a mensagem de entrada da coluna
        MOV AH,09H
        INT 21H

        MOV AH,01H          ;le o valor digitado pelo usuario (seleciona a coluna)
        INT 21H
        SUB AL,31H          ;transforma o valor em digito

        XOR AH,AH           ;limpa AH
        MOV SI,AX           ;move o valor de AX para SI (representa as colunas)

        LEA DX, dignum      ;le a mensagem de entrada do numero	pelo usuario
        MOV AH,09H
        INT 21H

        MOV AH,01H          ;le o valor digitado pelo usuario (seleciona o numero)
        INT 21H
        SUB AL,30H          ;transforma o valor em digito

        CMP AL, MATRIZRESP_PR[BX][SI]   ;compara o valor digitado pelo usuario com o valor da matriz de resposta

        JE ACERTOSI         ;se forem iguais, pula para ACERTOSI
        
        ;contador de erros
        PUSH DX             ;se for incorreto, incrementa o contador de erros
        XOR DL,DL
        MOV DL, conta_erros
        INC DL
        MOV conta_erros, DL
        POP DX
        ;fim do contador de erros

        JMP SAIRI
        XOR AX,AX

    ACERTOSI:              ;se for correto, move o valor para a matriz que eh exibida para o usuario
        ADD AL,30H
        MOV MATRIZPRIMEIRA[BX][SI],AL

        ;contador de acertos, que nao eh exibido para o usuario
        PUSH DX
        XOR DL,DL
        MOV DL, conta_acertos
        INC DL
        MOV conta_acertos,DL
        POP DX
        JMP SAIRI
        ;fim do contador de acertos

    SAIRI:
        popreg             ;resgata valores dos registradores           
        
        RET                ;retorna o procedimento a main
    VERIFICA_RESPI ENDP    ;fim do procedimento                    

    VERIFICA_RESPII PROC   ;procedimento que verifica se o jogador acertou ou errou (jogo 2),
        pushreg            ;possui a mesma estrutura do procedimento VERIFICA_RESPI, contudo eh
        limpareg           ;utilizada para o jogo 2, pois valores dos contadores de acertos sao diferentes

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
        
        RET                     ;retorna o procedimento a main
    VERIFICA_RESPII ENDP        ;fim do procedimento
        
    PERDEU_CONTADOR PROC        ;procedimento que verifica se o jogador perdeu o jogo atraves do contador de erros
        pushreg                 ;salva os valores dos registradores

        MOV DL, conta_erros     ;move para dl o valor do contador de erros
        CMP DL,3                ;compara se eh igual a 3
        popreg                  ;resgata os valores dos registradores
        
        RET                     ;retorna o procedimento a main
    PERDEU_CONTADOR ENDP        ;fim do procedimento

    PERDEU_MSG PROC             ;procedimento que exibe a mensagem que o jogador perdeu o jogo
        apagatela               ;apaga a tela
        MOV AH,09h
        LEA DX,perdeumsg        ;imprime a mensagem de derrota
        INT 21H

        MOV AH,01H              ;le o valor digitado pelo usuario, para que o jogo nao feche e volte para o menu
        INT 21H
        RET                     ;retorna o procedimento a main
    PERDEU_MSG ENDP             ;fim do procedimento

    GANHOU_CONTADOR PROC        ;procedimento que verifica se o jogador ganhou o jogo atraves do contador de acertos (jogo 1)
        pushreg
        
        MOV DL, conta_acertos   ;move para dl o valor do contador de acertos
        CMP DL, 51              ;numero de casas que o jogador deve acertar para ganhar o jogo 1
                                ;(as casas que estao com o 'X' e devem ser preenchidas).
        popreg
        RET                     ;retorna o procedimento a main
    GANHOU_CONTADOR ENDP        ;fim do procedimento

    GANHOU_CONTADORII PROC      ;procedimento que verifica se o jogador ganhou o jogo atraves do contador de acertos (jogo 2)
        pushreg                 ;foi necessario criar um procedimento diferente para o jogo 2, pois o numero de casas
                                ;que o jogador deve acertar eh diferente do jogo 1

        MOV DL, conta_acertos   ;move para dl o valor do contador de acertos
        CMP DL, 49              ;numero de casas que o jogador deve acertar para ganhar o jogo 2
                                ;(as casas que estao com o 'X' e devem ser preenchidas).
        popreg
        RET                     ;retorna o procedimento a main
    GANHOU_CONTADORII ENDP      ;fim do procedimento

    VENCEU_MSG PROC             ;procedimento que exibe a mensagem que o jogador venceu o jogo
        apagatela               ;apaga a tela
        MOV AH,09H              
        LEA DX, venceumsg       ;le a mensagem de vitoria
        INT 21H                 ;executa e imprime

        MOV AH,01H              ;le o valor digitado pelo usuario, para que o jogo nao feche e volte para o menu
        INT 21H         
        RET                     ;retorna o procedimento a main
    VENCEU_MSG ENDP             ;fim do procedimento

END MAIN                        ;fim do programa
