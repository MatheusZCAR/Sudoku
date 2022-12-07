.MODEL SMALL
p_linha  MACRO 
    mov ah,02
    mov dl,10
    int 21H
endm
pushreg  MACRO 
 push ax
 push bx
 push cx
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
.STACK 1000
.DATA

linha DW ?
coluna DW ?

sudoku1   DB 32,32,'a','b','c',32,'d','e','f',32,'g','h','i',32
          DB 0,201,205,205,205,205,205,205,205,205,205,205,205,187
          DB 'a',186,'5','3','X',179,'X','7','X',179,'X','X','X',186
          DB 'b',186,'6','X','X',179,'1','9','5',179,'X','X','X',186
          DB 'c',186,'X','9','8',179,'X','X','X',179,'X','6','X',186
          DB 0,186,196,196,196,179,196,196,196,179,196,196,196,186
          DB 'd',186,'8','X','X',179,'X','6','X',179,'X','X','3',186
          DB 'e',186,'4','X','X',179,'8','X','3',179,'X','X','1',186
          DB 'f',186,'7','X','X',179,'X','2','X',179,'X','X','6',186
          DB 0,186,196,196,196,179,196,196,196,179,196,196,196,186
          DB 'g',186,'X','6','X',179,'X','X','X',179,'2','8','X',186
          DB 'h',186,'X','X','X',179,'4','1','9',179,'X','X','5',186
          DB 'i',186,'X','X','X',179,'X','8','X',179,'X','7','9',186
          DB 0,200,205,205,205,205,205,205,205,205,205,205,205,188

sudoku2   DB 32,32,'a','b','c',32,'d','e','f',32,'g','h','i',32
          DB 0,201,205,205,205,205,205,205,205,205,205,205,205,187
          DB 'a',186,'X','X','X',179,'8','X','X',179,'X','3','2',186
          DB 'b',186,'X','8','1',179,'3','7','X',179,'X','X','X',186
          DB 'c',186,'6','X','3',179,'X','X','X',179,'1','X','8',186
          DB 0,186,196,196,196,179,196,196,196,179,196,196,196,186
          DB 'd',186,'5','9','X',179,'4','X','X',179,'3','8','X',186
          DB 'e',186,'X','X','6',179,'5','X','X',179,'X','X','X',186
          DB 'f',186,'7','X','8',179,'X','2','X',179,'X','X','5',186
          DB 0,186,196,196,196,179,196,196,196,179,196,196,196,186
          DB 'g',186,'X','X','X',179,'X','5','4',179,'2','X','X',186
          DB 'h',186,'X','X','X',179,'X','X','X',179,'5','X','X',186
          DB 'i',186,'4','2','5',179,'X','X','X',179,'8','1','7',186
          DB 0,200,205,205,205,205,205,205,205,205,205,205,205,188


.CODE
    MAIN PROC
        MOV AX,@DATA
        MOV DS,AX
        MOV ES,AX

        MOV AH,0h
        MOV AL,3h
        INT 10H

        XOR AX,AX

        MOV AH,09
        MOV AL,20H
        MOV BH,00
        MOV BL,6FH
        MOV CX,800H
        INT 10H

        MOV AX,03
        INT 10H
        XOR AX,AX

        MOV linha,14
        MOV coluna,14
        LEA bx, sudoku2
        CALL IMPRIME_SUDOKU
        p_linha
        
    
    MOV AH,4CH
    INT 21H
    MAIN ENDP



    IMPRIME_SUDOKU PROC
        pushreg 

        mov ah,02
        mov cx,linha

    outer:
        mov di,coluna
        xor si,si
    inner:
        mov dl, [bx][si]
        int 21H
        inc si
        dec DI
        jnz inner
        P_LINHA
        add bx,coluna
        loop outer
        popreg
        RET
    IMPRIME_SUDOKU ENDP
    end main