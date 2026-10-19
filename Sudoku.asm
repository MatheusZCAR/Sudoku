TITLE SUDOKU - JEAN OKABE REZENDE PITON (22013310) / MATHEUS ZANON CARITA (22014203)
;==============================================================================
; Sudoku em Assembly 8086 com interface grafica (DOS, VGA 320x200, mouse)
;
;   - 4 jogos (2 faceis, 1 medio, 1 dificil), todos com solucao unica
;   - Mouse: clique na casa e depois no numero do teclado numerico da tela
;   - Teclado: setas movem a selecao, 1-9 jogam, ESC volta ao menu
;   - Numero certo fica no tabuleiro; numero errado conta um erro (3 = derrota)
;   - Destaque da linha, coluna e quadrado da casa selecionada, e dos numeros
;     iguais ao da casa selecionada; cronometro; teclado numerico apaga os
;     numeros que ja foram todos colocados
;
; Montagem (fonte8x8.inc na mesma pasta):
;   JWasm     : jwasm -mz Sudoku.asm
;   MASM/LINK : masm Sudoku.asm;  e  link Sudoku.obj;
;   TASM      : tasm Sudoku.asm   e  tlink Sudoku.obj
; Rode no DOSBox (ou DOS real) para ter mouse e graficos VGA.
;==============================================================================
.MODEL SMALL
.STACK 400h

;------------------------------ cores (paleta propria a partir da cor 32) ----
COR_FUNDO   EQU 32
COR_CEL     EQU 33              ;casa normal
COR_PAR     EQU 34              ;linha / coluna / quadrado da casa selecionada
COR_SEL     EQU 35              ;casa selecionada
COR_IGUAL   EQU 36              ;casas com o mesmo numero da selecionada
COR_FINA    EQU 37              ;linhas finas
COR_GROSSA  EQU 38              ;linhas grossas (quadrados 3x3)
COR_TEXTO   EQU 39              ;numeros do jogo (branco)
COR_JOGADOR EQU 40              ;numeros colocados pelo jogador
COR_APAGADO EQU 41              ;texto cinza
COR_ERRO    EQU 42              ;vermelho
COR_BTN     EQU 43
COR_BTN_SOM EQU 44
COR_APERTO  EQU 45
COR_TITULO  EQU 46              ;ambar
COR_VERDE   EQU 47
COR_BTN_OFF EQU 48              ;botao desativado
COR_ERRO_ESC EQU 49             ;vermelho escuro
QTD_CORES   EQU 18

;------------------------------ geometria do tabuleiro -------------------------
TAB_X       EQU 4               ;canto superior esquerdo do tabuleiro
TAB_Y       EQU 3
TAB_TAM     EQU 194             ;9 casas de 20 + 6 linhas finas + 4 grossas de 2
CEL_TAM     EQU 20

; estados do jogo
JOGANDO     EQU 0
VENCEU      EQU 1
PERDEU      EQU 2

;------------------------------ botoes -----------------------------------------
; x, y, largura, altura, rotulo, acao, cor, cor da sombra, cor do texto, escala
BOTAO MACRO bx_,by_,bw_,bh_,rot,acao,cor,sombra,ctxt,esc
        DW bx_,by_,bw_,bh_
        DW OFFSET rot
        DB acao,cor,sombra,ctxt,esc,0
ENDM
TAM_BOTAO   EQU 16
B_X     EQU 0
B_Y     EQU 2
B_L     EQU 4
B_A     EQU 6
B_ROT   EQU 8
B_ACAO  EQU 10
B_COR   EQU 11
B_SOM   EQU 12
B_CTXT  EQU 13
B_ESC   EQU 14

.DATA
        INCLUDE fonte8x8.inc    ;bitmap dos caracteres (rotulo "fonte8x8")

;---------- paleta: R,G,B de 0 a 63 para as cores 32 a 49 ---------------------
paleta  DB  4, 5, 9             ;COR_FUNDO
        DB 11,13,19             ;COR_CEL
        DB 15,18,27             ;COR_PAR
        DB 18,30,52             ;COR_SEL
        DB 23,26,40             ;COR_IGUAL
        DB  6, 7,11             ;COR_FINA
        DB 34,38,48             ;COR_GROSSA
        DB 60,61,63             ;COR_TEXTO
        DB 62,42,12             ;COR_JOGADOR
        DB 28,31,38             ;COR_APAGADO
        DB 63,22,22             ;COR_ERRO
        DB 18,20,28             ;COR_BTN
        DB 10,11,17             ;COR_BTN_SOM
        DB 42,46,54             ;COR_APERTO
        DB 62,42,12             ;COR_TITULO
        DB 20,54,38             ;COR_VERDE
        DB  8, 9,14             ;COR_BTN_OFF
        DB 40, 8, 8             ;COR_ERRO_ESC

;---------- jogos ---------------------------------------------------------------
;jogo 1 - tabuleiro inicial (0 = casa vazia)
jogo1_p   DB 5,3,0,  0,7,0,  0,0,0
          DB 6,0,0,  1,9,5,  0,0,0
          DB 0,9,8,  0,0,0,  0,6,0
          DB 8,0,0,  0,6,0,  0,0,3
          DB 4,0,0,  8,0,3,  0,0,1
          DB 7,0,0,  0,2,0,  0,0,6
          DB 0,6,0,  0,0,0,  2,8,0
          DB 0,0,0,  4,1,9,  0,0,5
          DB 0,0,0,  0,8,0,  0,7,9
;jogo 1 - gabarito
jogo1_s   DB 5,3,4,  6,7,8,  9,1,2
          DB 6,7,2,  1,9,5,  3,4,8
          DB 1,9,8,  3,4,2,  5,6,7
          DB 8,5,9,  7,6,1,  4,2,3
          DB 4,2,6,  8,5,3,  7,9,1
          DB 7,1,3,  9,2,4,  8,5,6
          DB 9,6,1,  5,3,7,  2,8,4
          DB 2,8,7,  4,1,9,  6,3,5
          DB 3,4,5,  2,8,6,  1,7,9
;jogo 2 - tabuleiro inicial (0 = casa vazia)
jogo2_p   DB 0,0,0,  8,0,0,  0,3,2
          DB 0,8,1,  3,7,0,  0,0,0
          DB 6,0,3,  0,0,0,  1,0,8
          DB 5,9,0,  4,0,0,  3,8,0
          DB 0,0,6,  5,0,0,  0,0,0
          DB 7,0,8,  0,2,0,  0,0,5
          DB 0,0,0,  0,5,4,  2,0,0
          DB 0,0,0,  0,0,0,  5,0,0
          DB 4,2,5,  0,0,0,  8,1,7
;jogo 2 - gabarito
jogo2_s   DB 9,7,4,  8,1,5,  6,3,2
          DB 2,8,1,  3,7,6,  9,5,4
          DB 6,5,3,  2,4,9,  1,7,8
          DB 5,9,2,  4,6,7,  3,8,1
          DB 1,4,6,  5,3,8,  7,2,9
          DB 7,3,8,  9,2,1,  4,6,5
          DB 8,6,7,  1,5,4,  2,9,3
          DB 3,1,9,  7,8,2,  5,4,6
          DB 4,2,5,  6,9,3,  8,1,7
;jogo 3 - tabuleiro inicial (0 = casa vazia)
jogo3_p   DB 0,5,0,  0,0,7,  0,9,2
          DB 9,0,0,  0,2,0,  1,0,0
          DB 0,6,2,  0,0,4,  7,0,0
          DB 4,9,0,  0,6,0,  0,0,0
          DB 0,0,0,  0,0,0,  0,0,0
          DB 0,0,0,  0,7,0,  0,3,5
          DB 0,0,9,  7,0,0,  3,6,0
          DB 0,0,1,  0,4,0,  0,0,7
          DB 8,7,0,  3,0,0,  0,2,0
;jogo 3 - gabarito
jogo3_s   DB 3,5,4,  6,1,7,  8,9,2
          DB 9,8,7,  5,2,3,  1,4,6
          DB 1,6,2,  8,9,4,  7,5,3
          DB 4,9,3,  1,6,5,  2,7,8
          DB 7,2,5,  4,3,8,  6,1,9
          DB 6,1,8,  2,7,9,  4,3,5
          DB 5,4,9,  7,8,2,  3,6,1
          DB 2,3,1,  9,4,6,  5,8,7
          DB 8,7,6,  3,5,1,  9,2,4
;jogo 4 - tabuleiro inicial (0 = casa vazia)
jogo4_p   DB 0,0,0,  0,0,0,  0,0,0
          DB 0,6,3,  0,0,0,  0,5,0
          DB 7,0,0,  1,5,9,  3,0,0
          DB 0,5,0,  2,0,4,  0,0,0
          DB 0,0,2,  0,3,0,  9,0,0
          DB 0,0,0,  9,0,1,  0,7,0
          DB 0,0,8,  3,1,6,  0,0,2
          DB 0,7,0,  0,0,0,  6,8,0
          DB 0,0,0,  0,0,0,  0,0,0
;jogo 4 - gabarito
jogo4_s   DB 2,9,5,  6,4,3,  8,1,7
          DB 1,6,3,  8,7,2,  4,5,9
          DB 7,8,4,  1,5,9,  3,2,6
          DB 9,5,7,  2,6,4,  1,3,8
          DB 8,1,2,  5,3,7,  9,6,4
          DB 4,3,6,  9,8,1,  2,7,5
          DB 5,4,8,  3,1,6,  7,9,2
          DB 3,7,9,  4,2,5,  6,8,1
          DB 6,2,1,  7,9,8,  5,4,3

jogos_p   DW OFFSET jogo1_p, OFFSET jogo2_p, OFFSET jogo3_p, OFFSET jogo4_p
jogos_s   DW OFFSET jogo1_s, OFFSET jogo2_s, OFFSET jogo3_s, OFFSET jogo4_s
jogos_n   DW OFFSET n_jogo1, OFFSET n_jogo2, OFFSET n_jogo3, OFFSET n_jogo4
jogos_niv DW OFFSET t_facil, OFFSET t_facil, OFFSET t_medio, OFFSET t_dificil
jogos_cor DB COR_VERDE, COR_VERDE, COR_TITULO, COR_ERRO

;---------- textos --------------------------------------------------------------
t_sudoku DB 'SUDOKU$'
t_sub    DB 'em Assembly 8086$'
t_autor  DB 'por Jean Piton e Matheus Carita$'
n_jogo1  DB 'Jogo 1$'
n_jogo2  DB 'Jogo 2$'
n_jogo3  DB 'Jogo 3$'
n_jogo4  DB 'Jogo 4$'
t_facil  DB 'Facil$'
t_medio  DB 'Medio$'
t_dificil DB 'Dificil$'
t_erros  DB 'Erros$'
t_tempo  DB 'Tempo$'
t_voce   DB 'VOCE$'
t_venceu DB 'VENCEU$'
t_perdeu DB 'PERDEU$'
t_parab  DB 'Parabens!$'
t_3erros DB '3 erros...$'
t_tecla  DB 'ENTER ou$'
t_clique DB 'clique MENU$'
t_tchau  DB 'Obrigado por jogar Sudoku!',13,10,'$'
t_semmo  DB 'Sem mouse: use o teclado$'

m_jogo1  DB 'Jogo 1 - Facil$'
m_jogo2  DB 'Jogo 2 - Facil$'
m_jogo3  DB 'Jogo 3 - Medio$'
m_jogo4  DB 'Jogo 4 - Dificil$'
m_regras DB 'Como jogar$'
m_sair   DB 'Sair$'
r_menu   DB 'MENU (ESC)$'
r_1 DB '1$'
r_2 DB '2$'
r_3 DB '3$'
r_4 DB '4$'
r_5 DB '5$'
r_6 DB '6$'
r_7 DB '7$'
r_8 DB '8$'
r_9 DB '9$'

; tela "Como jogar": uma linha por string, termina com 0
t_comojogar DB 'COMO JOGAR$'
regras  DB 'Complete o tabuleiro 9x9 com numeros$'
        DB 'de 1 a 9 sem repetir nenhum numero na$'
        DB 'mesma linha, na mesma coluna ou no$'
        DB 'mesmo quadrado 3x3.$'
        DB '$'
        DB 'Numero certo: fica no tabuleiro.$'
        DB 'Numero errado: conta um erro.$'
        DB 'Com 3 erros voce perde o jogo!$'
        DB '$'
        DB 'MOUSE  : clique na casa e no numero$'
        DB 'TECLADO: setas movem, 1 a 9 jogam,$'
        DB '         ESC volta ao menu$'
        DB 0
t_voltar DB 'clique ou tecle para voltar$'

;---------- botoes do menu e do jogo -----------------------------------------------
botoes_menu LABEL BYTE
        BOTAO 60, 58,200,18,m_jogo1, '1',COR_BTN,COR_BTN_SOM,COR_TEXTO,1
        BOTAO 60, 80,200,18,m_jogo2, '2',COR_BTN,COR_BTN_SOM,COR_TEXTO,1
        BOTAO 60,102,200,18,m_jogo3, '3',COR_BTN,COR_BTN_SOM,COR_TEXTO,1
        BOTAO 60,124,200,18,m_jogo4, '4',COR_BTN,COR_BTN_SOM,COR_TEXTO,1
        BOTAO 60,146,200,18,m_regras,'H',COR_BTN,COR_BTN_SOM,COR_TITULO,1
        BOTAO 60,168,200,18,m_sair,  'Q',COR_BTN,COR_BTN_SOM,COR_TEXTO,1
NUM_MENU EQU 6

botoes_jogo LABEL BYTE
        BOTAO 206, 64,34,30,r_1,'1',COR_BTN,COR_BTN_SOM,COR_TEXTO,2
        BOTAO 244, 64,34,30,r_2,'2',COR_BTN,COR_BTN_SOM,COR_TEXTO,2
        BOTAO 282, 64,34,30,r_3,'3',COR_BTN,COR_BTN_SOM,COR_TEXTO,2
        BOTAO 206, 98,34,30,r_4,'4',COR_BTN,COR_BTN_SOM,COR_TEXTO,2
        BOTAO 244, 98,34,30,r_5,'5',COR_BTN,COR_BTN_SOM,COR_TEXTO,2
        BOTAO 282, 98,34,30,r_6,'6',COR_BTN,COR_BTN_SOM,COR_TEXTO,2
        BOTAO 206,132,34,30,r_7,'7',COR_BTN,COR_BTN_SOM,COR_TEXTO,2
        BOTAO 244,132,34,30,r_8,'8',COR_BTN,COR_BTN_SOM,COR_TEXTO,2
        BOTAO 282,132,34,30,r_9,'9',COR_BTN,COR_BTN_SOM,COR_TEXTO,2
        BOTAO 206,170,110,24,r_menu,'M',COR_BTN,COR_BTN_SOM,COR_TITULO,1
NUM_JOGO EQU 10

; posicao de cada casa dentro do tabuleiro (linhas grossas de 2 e finas de 1)
cel_pos  DB 2,23,44,66,87,108,130,151,172
; posicao das 4 linhas grossas
grossa   DB 0,64,128,192
; quadrado 3x3 de cada linha/coluna
quadro   DB 0,0,0,1,1,1,2,2,2

;---------- estado do jogo -----------------------------------------------------------
tab      DB 81 DUP(0)           ;tabuleiro atual (0 = vazio)
fixo     DB 81 DUP(0)           ;1 = numero que ja veio no jogo
sol_ptr  DW ?                   ;gabarito do jogo atual
jogo_num DW 0                   ;0..3
sel_l    DB 4                   ;casa selecionada
sel_c    DB 4
erros    DB 0
vazios   DB 0                   ;casas que faltam preencher
estado   DB JOGANDO
minutos  DB 0
segundos DB 0
ult_seg  DB 0FFh                ;ultimo segundo lido do relogio do DOS
mouse_ok DB 0
mouse_ant DB 0                  ;botao do mouse no ultimo teste
tempo_txt DB '00:00$'

; evento lido por le_evento
ev_tipo  DB 0                   ;0 = nada, 1 = tecla, 2 = clique
ev_ascii DB 0
ev_scan  DB 0
ev_x     DW 0
ev_y     DW 0

; parametros das rotinas de desenho
rx       DW ?
ry       DW ?
rw       DW ?
rh       DW ?
rcor     DB ?
tx       DW ?
ty       DW ?
tcor     DB ?
tesc     DB 1
apertado DB 0
apagado  DB 0                   ;1 = desenhar o botao como desativado
topo_b   DW ?
tab_bot  DW ?                   ;tabela de botoes da tela atual
num_bot  DW ?
cl_l     DB ?                   ;casa sendo desenhada
cl_c     DB ?

.CODE

main proc
        MOV ax,@DATA
        MOV ds,ax
        CLD

        MOV ax,0013h            ;modo grafico VGA 320x200, 256 cores
        INT 10h
        CALL carrega_paleta

        XOR ax,ax               ;inicializa o mouse
        INT 33h
        CMP ax,0FFFFh
        JNE m_menu
        MOV mouse_ok,1
        MOV ax,1                ;mostra o ponteiro
        INT 33h

m_menu:
        CALL tela_menu          ;AL = opcao escolhida
        CMP al,'Q'
        JE  m_fim
        CMP al,'H'
        JNE m_jogo
        CALL tela_regras
        JMP m_menu
m_jogo:
        SUB al,'1'              ;'1'..'4' -> 0..3
        XOR ah,ah
        MOV jogo_num,ax
        CALL jogar
        JMP m_menu

m_fim:
        XOR ax,ax               ;desliga o mouse
        INT 33h
        MOV ax,0003h            ;volta para o modo texto
        INT 10h
        LEA dx,t_tchau
        MOV ah,09h
        INT 21h
        MOV ax,4C00h
        INT 21h
main endp

;==============================================================================
;                                  TELAS
;==============================================================================

;------------------------------------------------------------------------------
; tela_menu: desenha o menu e espera uma escolha. Saida: AL = '1'..'4','H','Q'
;------------------------------------------------------------------------------
tela_menu proc
        CALL esconde_mouse
        CALL limpa_tela

        MOV tesc,4              ;titulo grande
        MOV tcor,COR_TITULO
        MOV ty,8
        LEA si,t_sudoku
        CALL texto_centro
        MOV tesc,1
        MOV tcor,COR_APAGADO
        MOV ty,44
        LEA si,t_sub
        CALL texto_centro
        MOV ty,191
        LEA si,t_autor
        CMP mouse_ok,1
        JE  tm_rodape
        MOV tcor,COR_ERRO       ;sem mouse: o rodape avisa para usar o teclado
        LEA si,t_semmo
tm_rodape:
        CALL texto_centro

        LEA si,botoes_menu
        MOV tab_bot,si
        MOV num_bot,NUM_MENU
        CALL desenha_botoes
        CALL mostra_mouse

tm_espera:
        CALL le_evento
        CMP ev_tipo,1
        JE  tm_tecla
        CMP ev_tipo,2
        JNE tm_espera
        CALL clique_botao       ;AL = acao do botao clicado (CF = 1 se nenhum)
        JC  tm_espera
        RET
tm_tecla:
        MOV al,ev_ascii
        CMP al,'1'
        JB  tm_outras
        CMP al,'4'
        JA  tm_outras
        RET
tm_outras:
        CMP al,27               ;ESC sai
        JE  tm_sair
        AND al,0DFh             ;maiuscula
        CMP al,'S'
        JE  tm_sair
        CMP al,'Q'
        JE  tm_sair
        CMP al,'H'
        JE  tm_ajuda
        CMP al,'C'
        JE  tm_ajuda
        CMP ev_ascii,'?'
        JE  tm_ajuda
        JMP tm_espera
tm_ajuda:
        MOV al,'H'
        RET
tm_sair:
        MOV al,'Q'
        RET
tela_menu endp

;------------------------------------------------------------------------------
; tela_regras: explica o jogo; volta com qualquer tecla ou clique
;------------------------------------------------------------------------------
tela_regras proc
        CALL esconde_mouse
        CALL limpa_tela
        MOV tesc,2
        MOV tcor,COR_TITULO
        MOV ty,12
        LEA si,t_comojogar
        CALL texto_centro

        MOV tesc,1
        MOV tcor,COR_TEXTO
        MOV tx,12
        MOV ty,44
        LEA si,regras
tr_linha:
        CMP BYTE PTR [si],0     ;fim da lista de linhas
        JE  tr_rodape
        CALL desenha_texto
tr_pula:
        INC si                  ;avanca ate depois do '$'
        CMP BYTE PTR [si-1],'$'
        JNE tr_pula
        ADD ty,11
        JMP tr_linha
tr_rodape:
        MOV tcor,COR_APAGADO
        MOV ty,184
        LEA si,t_voltar
        CALL texto_centro
        CALL mostra_mouse
tr_espera:
        CALL le_evento
        CMP ev_tipo,0
        JE  tr_espera
        RET
tela_regras endp

;------------------------------------------------------------------------------
; jogar: partida completa do jogo jogo_num; volta quando o jogador pede o menu
;------------------------------------------------------------------------------
jogar proc
        LEA si,botoes_jogo      ;botoes desta tela
        MOV tab_bot,si
        MOV num_bot,NUM_JOGO
        CALL inicia_jogo
        CALL desenha_jogo

j_laco:
        CALL atualiza_tempo
        CALL le_evento
        CMP ev_tipo,1
        JE  j_tecla
        CMP ev_tipo,2
        JNE j_laco

        ;----- clique -----
        CMP estado,JOGANDO
        JNE j_clique_botao
        CALL acha_casa          ;clicou numa casa? DH = linha, DL = coluna
        JC  j_clique_botao
        MOV sel_l,dh
        MOV sel_c,dl
        CALL desenha_tabuleiro
        JMP j_laco
j_clique_botao:
        CALL clique_botao       ;AL = acao
        JC  j_laco
        CMP al,'M'
        JE  j_volta
        CMP estado,JOGANDO
        JNE j_laco
        CALL joga_numero        ;botoes 1..9
        JMP j_laco
j_volta:
        RET                     ;volta ao menu (perto dos saltos, que no 8086 alcancam so 128 bytes)

        ;----- teclado -----
j_tecla:
        MOV al,ev_ascii
        CMP al,27               ;ESC: menu
        JE  j_volta
        CMP estado,JOGANDO
        JE  j_jogando
        CMP al,13               ;jogo acabou: ENTER ou espaco tambem voltam
        JE  j_volta
        CMP al,' '
        JE  j_volta
        JMP j_laco
j_jogando:
        CMP al,'1'
        JB  j_setas
        CMP al,'9'
        JA  j_setas
        CALL pisca_numero       ;mostra o botao da tela "apertando"
        CALL joga_numero
        CMP estado,JOGANDO
        JNE j_fim_tecla
        CALL desenha_numpad
j_fim_tecla:
        JMP j_laco
j_setas:
        MOV ah,ev_scan
        MOV dh,sel_l
        MOV dl,sel_c
        CMP ah,48h              ;cima
        JNE j_nao_cima
        DEC dh
        JNS j_move
        MOV dh,8
        JMP j_move
j_nao_cima:
        CMP ah,50h              ;baixo
        JNE j_nao_baixo
        INC dh
        CMP dh,9
        JB  j_move
        MOV dh,0
        JMP j_move
j_nao_baixo:
        CMP ah,4Bh              ;esquerda
        JNE j_nao_esq
        DEC dl
        JNS j_move
        MOV dl,8
        JMP j_move
j_nao_esq:
        CMP ah,4Dh              ;direita
        JNE j_ignora
        INC dl
        CMP dl,9
        JB  j_move
        MOV dl,0
j_move:
        MOV sel_l,dh
        MOV sel_c,dl
        CALL desenha_tabuleiro
j_ignora:
        JMP j_laco

j_sai:
        RET
jogar endp

;==============================================================================
;                              LOGICA DO JOGO
;==============================================================================

;------------------------------------------------------------------------------
; inicia_jogo: copia o jogo escolhido para o tabuleiro e zera tudo
;   (o tabuleiro original nunca e alterado, entao da para jogar de novo)
;------------------------------------------------------------------------------
inicia_jogo proc
        MOV bx,jogo_num
        SHL bx,1
        MOV si,jogos_p[bx]
        MOV ax,jogos_s[bx]
        MOV sol_ptr,ax
        XOR bx,bx
        MOV vazios,0
ij_laco:
        MOV al,[si+bx]
        MOV tab[bx],al
        MOV fixo[bx],1
        CMP al,0
        JNE ij_prox
        MOV fixo[bx],0
        INC vazios
ij_prox:
        INC bx
        CMP bx,81
        JB  ij_laco
        MOV erros,0
        MOV estado,JOGANDO
        MOV minutos,0
        MOV segundos,0
        MOV sel_l,4             ;comeca no centro
        MOV sel_c,4
        MOV ah,2Ch              ;segundo atual do relogio
        INT 21h
        MOV ult_seg,dh
        RET
inicia_jogo endp

;------------------------------------------------------------------------------
; indice: BX = linha * 9 + coluna  (DH = linha, DL = coluna)
;------------------------------------------------------------------------------
indice proc
        PUSH ax
        MOV al,dh
        XOR ah,ah
        MOV bx,ax
        SHL bx,1                ;linha * 8 ...
        SHL bx,1
        SHL bx,1
        ADD bx,ax               ;... + linha = linha * 9
        MOV al,dl
        ADD bx,ax
        POP ax
        RET
indice endp

;------------------------------------------------------------------------------
; joga_numero: tenta colocar o numero AL ('1'..'9') na casa selecionada
;------------------------------------------------------------------------------
joga_numero proc
        SUB al,'0'
        MOV cl,al               ;CL = numero (1..9)
        MOV dh,sel_l
        MOV dl,sel_c
        CALL indice             ;BX = casa
        CMP tab[bx],0           ;casa ja preenchida (do jogo ou acertada): nada a fazer
        JNE jn_recusa
        PUSH bx                 ;numero que ja esta nas 9 casas tambem e ignorado
        XOR bx,bx
        MOV ch,0
jn_conta:
        CMP tab[bx],cl
        JNE jn_conta_prox
        INC ch
jn_conta_prox:
        INC bx
        CMP bx,81
        JB  jn_conta
        POP bx
        CMP ch,9
        JB  jn_vazia
jn_recusa:
        CALL bipe
        RET
jn_vazia:
        MOV si,sol_ptr
        CMP [si+bx],cl          ;confere com o gabarito
        JNE jn_errou

        MOV tab[bx],cl          ;acertou
        DEC vazios
        JNZ jn_redesenha
        MOV estado,VENCEU       ;era a ultima casa
        CALL desenha_jogo
        RET
jn_redesenha:
        CALL desenha_tabuleiro
        CALL desenha_numpad     ;o numero pode ter se completado
        RET

jn_errou:
        INC erros
        CALL bipe
        CALL pisca_erro         ;mostra o numero errado em vermelho por um instante
        CMP erros,3
        JB  jn_painel
        MOV estado,PERDEU
        CALL desenha_jogo
        RET
jn_painel:
        CALL desenha_tabuleiro
        CALL desenha_erros
        RET
joga_numero endp

;------------------------------------------------------------------------------
; atualiza_tempo: conta os segundos de jogo (usa o relogio do DOS, INT 21h/2Ch)
;------------------------------------------------------------------------------
atualiza_tempo proc
        MOV ah,2Ch
        INT 21h                 ;DH = segundos
        CMP dh,ult_seg
        JE  at_sai
        MOV ult_seg,dh
        CMP estado,JOGANDO      ;o cronometro para quando o jogo acaba
        JNE at_sai
        INC segundos
        CMP segundos,60
        JB  at_desenha
        MOV segundos,0
        CMP minutos,99
        JAE at_desenha
        INC minutos
at_desenha:
        CALL desenha_tempo
at_sai:
        RET
atualiza_tempo endp

;------------------------------------------------------------------------------
; acha_casa: (ev_x, ev_y) -> DH = linha, DL = coluna. CF = 1 se fora do tabuleiro
;------------------------------------------------------------------------------
acha_casa proc
        MOV ax,ev_x
        SUB ax,TAB_X
        JB  ac_fora
        CALL pos_para_casa
        JC  ac_fora
        MOV dl,al
        MOV ax,ev_y
        SUB ax,TAB_Y
        JB  ac_fora
        CALL pos_para_casa
        JC  ac_fora
        MOV dh,al
        CLC
        RET
ac_fora:
        STC
        RET
acha_casa endp

pos_para_casa proc              ;AX = posicao dentro do tabuleiro -> AL = casa (0..8)
        PUSH bx
        PUSH cx
        XOR bx,bx
pc_laco:
        MOV cl,cel_pos[bx]
        XOR ch,ch
        CMP ax,cx
        JB  pc_prox
        ADD cx,CEL_TAM
        CMP ax,cx
        JAE pc_prox
        MOV al,bl               ;achou (clique em cima de uma linha nao conta)
        CLC
        JMP pc_sai
pc_prox:
        INC bx
        CMP bx,9
        JB  pc_laco
        STC
pc_sai:
        POP cx
        POP bx
        RET
pos_para_casa endp

;==============================================================================
;                              DESENHO DO JOGO
;==============================================================================

desenha_jogo proc
        CALL esconde_mouse
        CALL limpa_tela
        CALL desenha_tabuleiro
        CALL desenha_painel
        CALL mostra_mouse
        RET
desenha_jogo endp

;------------------------------------------------------------------------------
; desenha_tabuleiro: linhas e as 81 casas
;------------------------------------------------------------------------------
desenha_tabuleiro proc
        PUSH ax
        PUSH bx
        PUSH cx
        CALL esconde_mouse
        MOV rx,TAB_X            ;fundo = cor das linhas finas
        MOV ry,TAB_Y
        MOV rw,TAB_TAM
        MOV rh,TAB_TAM
        MOV rcor,COR_FINA
        CALL retangulo

        MOV rcor,COR_GROSSA     ;linhas grossas que separam os quadrados 3x3
        XOR bx,bx
dtb_grossa:
        MOV al,grossa[bx]
        XOR ah,ah
        MOV cx,ax
        ADD ax,TAB_X            ;vertical
        MOV rx,ax
        MOV ry,TAB_Y
        MOV rw,2
        MOV rh,TAB_TAM
        CALL retangulo
        MOV ax,cx               ;horizontal
        ADD ax,TAB_Y
        MOV ry,ax
        MOV rx,TAB_X
        MOV rw,TAB_TAM
        MOV rh,2
        CALL retangulo
        INC bx
        CMP bx,4
        JB  dtb_grossa

        MOV cl_l,0
dtb_linha:
        MOV cl_c,0
dtb_coluna:
        CALL desenha_casa
        INC cl_c
        CMP cl_c,9
        JB  dtb_coluna
        INC cl_l
        CMP cl_l,9
        JB  dtb_linha

        CALL mostra_mouse
        POP cx
        POP bx
        POP ax
        RET
desenha_tabuleiro endp

;------------------------------------------------------------------------------
; desenha_casa: desenha a casa (cl_l, cl_c) com a cor de destaque certa
;------------------------------------------------------------------------------
desenha_casa proc
        PUSH ax
        PUSH bx
        PUSH cx
        PUSH dx
        PUSH si

        MOV dh,cl_l             ;posicao na tela
        MOV dl,cl_c
        CALL casa_xy            ;rx, ry
        MOV rw,CEL_TAM
        MOV rh,CEL_TAM

        CALL indice
        MOV cl,tab[bx]          ;CL = numero desta casa

        MOV dh,sel_l            ;CH = numero da casa selecionada
        MOV dl,sel_c
        PUSH bx
        CALL indice
        MOV ch,tab[bx]
        POP bx

        MOV al,COR_CEL          ;escolhe a cor de fundo
        CMP estado,JOGANDO
        JNE dc_pinta
        MOV ah,cl_l
        CMP ah,sel_l
        JNE dc_nao_linha
        MOV ah,cl_c
        CMP ah,sel_c
        JNE dc_parente
        MOV al,COR_SEL          ;a propria casa selecionada
        JMP dc_pinta
dc_nao_linha:
        MOV ah,cl_c             ;mesma coluna?
        CMP ah,sel_c
        JE  dc_parente
        PUSH bx                 ;mesmo quadrado 3x3?
        MOV bl,cl_l
        XOR bh,bh
        MOV ah,quadro[bx]
        MOV bl,sel_l
        CMP ah,quadro[bx]
        JNE dc_outro_quadro
        MOV bl,cl_c
        MOV ah,quadro[bx]
        MOV bl,sel_c
        CMP ah,quadro[bx]
        JNE dc_outro_quadro
        POP bx
        JMP dc_parente
dc_outro_quadro:
        POP bx
        CMP cl,0                ;mesmo numero da casa selecionada?
        JE  dc_pinta
        CMP cl,ch
        JNE dc_pinta
        MOV al,COR_IGUAL
        JMP dc_pinta
dc_parente:
        MOV al,COR_PAR
dc_pinta:
        MOV rcor,al
        CALL retangulo

        MOV tesc,2              ;numero (16x16 centralizado na casa de 20x20)
        MOV ax,rx
        ADD ax,2
        MOV tx,ax
        MOV ax,ry
        ADD ax,2
        MOV ty,ax
        CMP cl,0
        JE  dc_vazia
        MOV tcor,COR_TEXTO
        CMP fixo[bx],1
        JE  dc_escreve
        MOV tcor,COR_JOGADOR
        JMP dc_escreve
dc_vazia:
        CMP estado,PERDEU       ;perdeu: mostra a resposta em vermelho
        JNE dc_sai
        MOV si,sol_ptr
        MOV cl,[si+bx]
        MOV tcor,COR_ERRO
dc_escreve:
        MOV al,cl
        ADD al,'0'
        CALL desenha_char
dc_sai:
        POP si
        POP dx
        POP cx
        POP bx
        POP ax
        RET
desenha_casa endp

casa_xy proc                    ;DH = linha, DL = coluna -> rx, ry (canto da casa)
        PUSH ax
        PUSH bx
        MOV bl,dl
        XOR bh,bh
        MOV al,cel_pos[bx]
        XOR ah,ah
        ADD ax,TAB_X
        MOV rx,ax
        MOV bl,dh
        MOV al,cel_pos[bx]
        XOR ah,ah
        ADD ax,TAB_Y
        MOV ry,ax
        POP bx
        POP ax
        RET
casa_xy endp

;------------------------------------------------------------------------------
; pisca_erro: mostra o numero errado (CL) na casa selecionada, em vermelho
;------------------------------------------------------------------------------
pisca_erro proc
        PUSH ax
        PUSH dx
        CALL esconde_mouse
        MOV dh,sel_l
        MOV dl,sel_c
        CALL casa_xy
        MOV rw,CEL_TAM
        MOV rh,CEL_TAM
        MOV rcor,COR_ERRO_ESC
        CALL retangulo
        MOV ax,rx
        ADD ax,2
        MOV tx,ax
        MOV ax,ry
        ADD ax,2
        MOV ty,ax
        MOV tesc,2
        MOV tcor,COR_ERRO
        MOV al,cl
        ADD al,'0'
        CALL desenha_char
        CALL mostra_mouse
        MOV cx,8                ;~0,4 segundo
pe_espera:
        CALL espera_tique
        LOOP pe_espera
        POP dx
        POP ax
        RET
pisca_erro endp

;------------------------------------------------------------------------------
; desenha_painel: lado direito (titulo, jogo, erros, tempo, numeros, menu)
;------------------------------------------------------------------------------
desenha_painel proc
        CALL esconde_mouse
        MOV tesc,2
        MOV tcor,COR_TITULO
        MOV tx,213
        MOV ty,4
        LEA si,t_sudoku
        CALL desenha_texto

        MOV bx,jogo_num         ;"Jogo N" e o nivel, colorido
        SHL bx,1
        MOV tesc,1
        MOV tcor,COR_TEXTO
        MOV tx,207
        MOV ty,26
        MOV si,jogos_n[bx]
        CALL desenha_texto
        MOV si,jogos_niv[bx]
        SHR bx,1
        MOV al,jogos_cor[bx]
        MOV tcor,al
        MOV ax,316
        CALL texto_direita

        MOV tcor,COR_APAGADO
        MOV tx,207
        MOV ty,38
        LEA si,t_erros
        CALL desenha_texto
        MOV ty,50
        LEA si,t_tempo
        CALL desenha_texto
        CALL desenha_erros
        CALL desenha_tempo

        CMP estado,JOGANDO
        JE  dp_numpad
        CALL desenha_fim        ;mensagem de vitoria/derrota no lugar dos numeros
        JMP dp_menu
dp_numpad:
        CALL desenha_numpad
dp_menu:
        LEA si,botoes_jogo+9*TAM_BOTAO  ;botao MENU
        MOV al,0
        CALL desenha_botao
        CALL mostra_mouse
        RET
desenha_painel endp

;------------------------------------------------------------------------------
; desenha_erros: 3 quadradinhos, vermelhos para cada erro cometido
;------------------------------------------------------------------------------
desenha_erros proc
        PUSH ax
        PUSH cx
        CALL esconde_mouse
        MOV rx,286
        MOV ry,38
        MOV rw,8
        MOV rh,8
        MOV cl,0
de_laco:
        MOV rcor,COR_CEL
        CMP cl,erros
        JAE de_pinta
        MOV rcor,COR_ERRO
de_pinta:
        CALL retangulo
        ADD rx,11
        INC cl
        CMP cl,3
        JB  de_laco
        CALL mostra_mouse
        POP cx
        POP ax
        RET
desenha_erros endp

;------------------------------------------------------------------------------
; desenha_tempo: "mm:ss" alinhado a direita
;------------------------------------------------------------------------------
desenha_tempo proc
        PUSH ax
        PUSH si
        PUSH di
        CALL esconde_mouse
        MOV al,minutos
        LEA di,tempo_txt
        CALL dois_digitos
        MOV al,segundos
        LEA di,tempo_txt+3
        CALL dois_digitos
        MOV rx,270              ;apaga o tempo anterior
        MOV ry,50
        MOV rw,46
        MOV rh,8
        MOV rcor,COR_FUNDO
        CALL retangulo
        MOV tesc,1
        MOV tcor,COR_TEXTO
        MOV ty,50
        LEA si,tempo_txt
        MOV ax,316
        CALL texto_direita
        CALL mostra_mouse
        POP di
        POP si
        POP ax
        RET
desenha_tempo endp

dois_digitos proc               ;AL (0..99) -> dois caracteres em [DI]
        MOV ah,'0'
dd_dezena:
        CMP al,10
        JB  dd_fim
        SUB al,10
        INC ah
        JMP dd_dezena
dd_fim:
        ADD al,'0'
        MOV [di],ah
        MOV [di+1],al
        RET
dois_digitos endp

;------------------------------------------------------------------------------
; desenha_numpad: botoes 1..9; numero que ja tem as 9 casas preenchidas fica apagado
;------------------------------------------------------------------------------
desenha_numpad proc
        PUSH ax
        PUSH bx
        PUSH cx
        PUSH si
        LEA si,botoes_jogo
        MOV cl,1
dn_laco:
        MOV ch,0                ;conta quantas vezes o numero CL aparece
        XOR bx,bx
dn_conta:
        CMP tab[bx],cl
        JNE dn_prox
        INC ch
dn_prox:
        INC bx
        CMP bx,81
        JB  dn_conta
        MOV apagado,0
        CMP ch,9
        JB  dn_desenha
        MOV apagado,1
dn_desenha:
        MOV al,0
        CALL desenha_botao
        MOV apagado,0
        ADD si,TAM_BOTAO
        INC cl
        CMP cl,9
        JBE dn_laco
        POP si
        POP cx
        POP bx
        POP ax
        RET
desenha_numpad endp

;------------------------------------------------------------------------------
; desenha_fim: mensagem de vitoria ou derrota
;------------------------------------------------------------------------------
desenha_fim proc
        MOV rx,206
        MOV ry,64
        MOV rw,110
        MOV rh,100
        MOV rcor,COR_FUNDO
        CALL retangulo

        MOV tesc,2
        MOV tcor,COR_VERDE
        CMP estado,VENCEU
        JE  df_cor
        MOV tcor,COR_ERRO
df_cor:
        MOV ty,72
        LEA si,t_voce
        CALL texto_painel
        MOV ty,92
        LEA si,t_venceu
        CMP estado,VENCEU
        JE  df_titulo
        LEA si,t_perdeu
df_titulo:
        CALL texto_painel

        MOV tesc,1
        MOV tcor,COR_TEXTO
        MOV ty,118
        LEA si,t_parab
        CMP estado,VENCEU
        JE  df_frase
        LEA si,t_3erros
df_frase:
        CALL texto_painel
        MOV tcor,COR_APAGADO
        MOV ty,140
        LEA si,t_tecla
        CALL texto_painel
        MOV ty,151
        LEA si,t_clique
        CALL texto_painel
        RET
desenha_fim endp

texto_painel proc               ;centraliza o texto SI na coluna do painel (206..316)
        PUSH ax
        CALL largura_texto
        NEG ax
        ADD ax,110
        SHR ax,1
        ADD ax,206
        MOV tx,ax
        CALL desenha_texto
        POP ax
        RET
texto_painel endp

;------------------------------------------------------------------------------
; pisca_numero: AL = '1'..'9', mostra o botao do numero apertado por um instante
;------------------------------------------------------------------------------
pisca_numero proc
        PUSH ax
        PUSH cx
        PUSH si
        SUB al,'1'
        XOR ah,ah
        MOV cl,4
        SHL ax,cl               ;* TAM_BOTAO (16)
        LEA si,botoes_jogo
        ADD si,ax
        MOV al,1
        CALL desenha_botao
        CALL espera_tique
        CALL espera_tique
        MOV al,0
        CALL desenha_botao
        POP si
        POP cx
        POP ax
        RET
pisca_numero endp

;==============================================================================
;                          ENTRADA (TECLADO E MOUSE)
;==============================================================================

;------------------------------------------------------------------------------
; le_evento: verifica teclado e mouse sem esperar.
;   ev_tipo = 0 (nada), 1 (tecla: ev_ascii, ev_scan) ou 2 (clique: ev_x, ev_y)
;------------------------------------------------------------------------------
le_evento proc
        PUSH ax
        PUSH bx
        PUSH cx
        PUSH dx
        MOV ev_tipo,0
        MOV ah,01h              ;tem tecla?
        INT 16h
        JZ  le_mouse
        MOV ah,00h
        INT 16h
        MOV ev_ascii,al
        MOV ev_scan,ah
        MOV ev_tipo,1
        JMP le_sai
le_mouse:
        CMP mouse_ok,1
        JNE le_sai
        MOV ax,3
        INT 33h
        AND bl,1                ;botao esquerdo
        MOV al,mouse_ant
        MOV mouse_ant,bl
        CMP bl,1                ;so conta quando o botao acabou de ser apertado
        JNE le_sai
        CMP al,0
        JNE le_sai
        SHR cx,1                ;no modo 13h o driver usa x de 0 a 639
        MOV ev_x,cx
        MOV ev_y,dx
        MOV ev_tipo,2
le_sai:
        POP dx
        POP cx
        POP bx
        POP ax
        RET
le_evento endp

;------------------------------------------------------------------------------
; clique_botao: o clique (ev_x, ev_y) caiu num botao da tela atual?
;   Mostra o botao apertado ate soltar. Saida: AL = acao, CF = 1 se nao valeu
;------------------------------------------------------------------------------
clique_botao proc
        PUSH bx
        PUSH cx
        PUSH dx
        PUSH si
        MOV cx,ev_x
        MOV dx,ev_y
        CALL acha_botao
        JC  cb_nada
        CMP tab_bot,OFFSET botoes_jogo  ;numero ja completo ou jogo acabado: botao desativado
        JNE cb_aperta
        CMP BYTE PTR [si+B_ACAO],'M'
        JE  cb_aperta
        CMP estado,JOGANDO
        JNE cb_nada
cb_aperta:
        MOV al,1
        CALL desenha_botao
cb_espera:
        MOV ax,3                ;espera soltar
        INT 33h
        TEST bl,1
        JNZ cb_espera
        MOV mouse_ant,0
        SHR cx,1
        PUSH si
        CALL acha_botao         ;soltou em cima do mesmo botao?
        MOV bx,si
        POP si
        PUSHF
        MOV al,0
        CMP tab_bot,OFFSET botoes_jogo
        JNE cb_redesenha
        CMP BYTE PTR [si+B_ACAO],'M'
        JE  cb_redesenha
        CALL desenha_numpad     ;redesenha com o estado (apagado ou nao) correto
        JMP cb_redesenhado
cb_redesenha:
        CALL desenha_botao
cb_redesenhado:
        POPF
        JC  cb_nada
        CMP bx,si
        JNE cb_nada
        MOV al,[si+B_ACAO]
        CLC
        JMP cb_sai
cb_nada:
        STC
cb_sai:
        POP si
        POP dx
        POP cx
        POP bx
        RET
clique_botao endp

;------------------------------------------------------------------------------
; acha_botao: CX = x, DX = y -> SI = botao da tabela tab_bot (CF = 1 se nenhum)
;------------------------------------------------------------------------------
acha_botao proc
        PUSH ax
        PUSH bx
        MOV si,tab_bot
        MOV bx,num_bot
ab_laco:
        MOV ax,[si+B_X]
        CMP cx,ax
        JB  ab_prox
        ADD ax,[si+B_L]
        CMP cx,ax
        JAE ab_prox
        MOV ax,[si+B_Y]
        CMP dx,ax
        JB  ab_prox
        ADD ax,[si+B_A]
        CMP dx,ax
        JAE ab_prox
        CLC
        JMP ab_sai
ab_prox:
        ADD si,TAM_BOTAO
        DEC bx
        JNZ ab_laco
        STC
ab_sai:
        POP bx
        POP ax
        RET
acha_botao endp

;------------------------------------------------------------------------------
; esconde_mouse / mostra_mouse: o ponteiro some enquanto desenhamos
;------------------------------------------------------------------------------
esconde_mouse proc
        CMP mouse_ok,1
        JNE em_sai
        PUSH ax
        MOV ax,2
        INT 33h
        POP ax
em_sai:
        RET
esconde_mouse endp

mostra_mouse proc
        CMP mouse_ok,1
        JNE mm_sai
        PUSH ax
        MOV ax,1
        INT 33h
        POP ax
mm_sai:
        RET
mostra_mouse endp

;------------------------------------------------------------------------------
; espera_tique: espera o relogio da BIOS avancar (1 tique = ~55 ms)
;------------------------------------------------------------------------------
espera_tique proc
        PUSH ax
        PUSH bx
        PUSH cx
        PUSH dx
        MOV ah,00h
        INT 1Ah
        MOV bx,dx
et_laco:
        MOV ah,00h
        INT 1Ah
        CMP dx,bx
        JE  et_laco
        POP dx
        POP cx
        POP bx
        POP ax
        RET
espera_tique endp

bipe proc
        PUSH ax
        PUSH dx
        MOV dl,7
        MOV ah,02h
        INT 21h
        POP dx
        POP ax
        RET
bipe endp

;==============================================================================
;                          PRIMITIVAS DE DESENHO (VGA 13h)
;==============================================================================

carrega_paleta proc             ;cores 32..49 (porta 3C8h = indice, 3C9h = R,G,B)
        MOV dx,3C8h
        MOV al,COR_FUNDO
        OUT dx,al
        INC dx
        LEA si,paleta
        MOV cx,QTD_CORES*3
cp_laco:
        MOV al,[si]
        OUT dx,al
        INC si
        LOOP cp_laco
        RET
carrega_paleta endp

limpa_tela proc
        MOV rx,0
        MOV ry,0
        MOV rw,320
        MOV rh,200
        MOV rcor,COR_FUNDO
        CALL retangulo
        RET
limpa_tela endp

vezes320 proc                   ;AX = AX * 320 = AX * 256 + AX * 64
        PUSH cx
        PUSH dx
        MOV dx,ax
        MOV cl,8
        SHL ax,cl
        MOV cl,6
        SHL dx,cl
        ADD ax,dx
        POP dx
        POP cx
        RET
vezes320 endp

retangulo proc                  ;preenche (rx, ry, rw, rh) com rcor
        PUSH ax
        PUSH bx
        PUSH cx
        PUSH di
        PUSH es
        MOV ax,0A000h
        MOV es,ax
        MOV ax,ry
        CALL vezes320
        ADD ax,rx
        MOV di,ax
        MOV bx,rh
        MOV al,rcor
re_linha:
        CMP bx,0
        JE  re_fim
        PUSH di
        MOV cx,rw
        REP STOSB
        POP di
        ADD di,320
        DEC bx
        JMP re_linha
re_fim:
        POP es
        POP di
        POP cx
        POP bx
        POP ax
        RET
retangulo endp

pixel proc                      ;ponto (AX = x, BX = y) com a cor DL
        PUSH ax
        PUSH di
        PUSH es
        MOV di,ax
        MOV ax,bx
        CALL vezes320
        ADD di,ax
        MOV ax,0A000h
        MOV es,ax
        MOV es:[di],dl
        POP es
        POP di
        POP ax
        RET
pixel endp

;------------------------------------------------------------------------------
; desenha_char: caractere AL em (tx, ty), cor tcor, escala tesc (1, 2, 3, 4...)
;------------------------------------------------------------------------------
desenha_char proc
        PUSH ax
        PUSH bx
        PUSH cx
        PUSH dx
        PUSH si
        PUSH di
        PUSH es

        CMP al,32               ;fora da fonte vira '?'
        JB  dch_troca
        CMP al,129
        JBE dch_ok
dch_troca:
        MOV al,'?'
dch_ok:
        SUB al,32               ;SI = fonte8x8 + (caractere - 32) * 8
        XOR ah,ah
        MOV cl,3
        SHL ax,cl
        MOV si,ax
        ADD si,OFFSET fonte8x8

        MOV ax,ty
        CALL vezes320
        ADD ax,tx
        MOV di,ax
        MOV ax,0A000h
        MOV es,ax
        MOV bh,8                ;8 linhas
dch_linha:
        MOV ah,[si]             ;bits da linha (bit 7 = pixel da esquerda)
        INC si
        MOV bl,8                ;8 colunas
        PUSH di
dch_coluna:
        SHL ah,1
        JNC dch_pula
        PUSH di                 ;pinta um quadrado de tesc x tesc
        MOV dh,tesc
dch_bloco:
        PUSH di
        MOV al,tcor
        MOV cl,tesc
        XOR ch,ch
        REP STOSB
        POP di
        ADD di,320
        DEC dh
        JNZ dch_bloco
        POP di
dch_pula:
        MOV cl,tesc
        XOR ch,ch
        ADD di,cx               ;proxima coluna
        DEC bl
        JNZ dch_coluna
        POP di
        MOV cl,tesc             ;proxima linha: desce tesc linhas de tela
dch_desce:
        ADD di,320
        DEC cl
        JNZ dch_desce
        DEC bh
        JNZ dch_linha

        POP es
        POP di
        POP si
        POP dx
        POP cx
        POP bx
        POP ax
        RET
desenha_char endp

largura_texto proc              ;AX = largura em pixels do texto DS:SI (ate '$')
        PUSH bx
        PUSH cx
        PUSH si
        XOR ax,ax
lt_laco:
        CMP BYTE PTR [si],'$'
        JE  lt_fim
        INC ax
        INC si
        JMP lt_laco
lt_fim:
        MOV cl,3                ;* 8 pixels
        SHL ax,cl
        MOV bx,ax               ;* tesc (somas repetidas, tesc e pequeno)
        MOV cl,tesc
        DEC cl
        JZ  lt_sai
lt_mult:
        ADD ax,bx
        DEC cl
        JNZ lt_mult
lt_sai:
        POP si
        POP cx
        POP bx
        RET
largura_texto endp

desenha_texto proc              ;escreve DS:SI (ate '$') a partir de (tx, ty)
        PUSH ax
        PUSH bx
        PUSH cx
        PUSH si
        PUSH tx
        MOV bx,8                ;passo = 8 * tesc
        MOV cl,tesc
        DEC cl
        JZ  dt_laco
dt_passo:
        ADD bx,8
        DEC cl
        JNZ dt_passo
dt_laco:
        MOV al,[si]
        CMP al,'$'
        JE  dt_fim
        CALL desenha_char
        ADD tx,bx
        INC si
        JMP dt_laco
dt_fim:
        POP tx
        POP si
        POP cx
        POP bx
        POP ax
        RET
desenha_texto endp

texto_direita proc              ;escreve DS:SI terminando na coluna AX
        PUSH ax
        PUSH bx
        MOV bx,ax
        CALL largura_texto
        SUB bx,ax
        MOV tx,bx
        CALL desenha_texto
        POP bx
        POP ax
        RET
texto_direita endp

texto_centro proc               ;escreve DS:SI centralizado na tela
        PUSH ax
        CALL largura_texto
        NEG ax
        ADD ax,320
        SHR ax,1
        MOV tx,ax
        CALL desenha_texto
        POP ax
        RET
texto_centro endp

;------------------------------------------------------------------------------
; desenha_botoes: todos os botoes da tabela tab_bot
;------------------------------------------------------------------------------
desenha_botoes proc
        PUSH ax
        PUSH cx
        PUSH si
        MOV si,tab_bot
        MOV cx,num_bot
dbs_laco:
        MOV al,0
        CALL desenha_botao
        ADD si,TAM_BOTAO
        LOOP dbs_laco
        POP si
        POP cx
        POP ax
        RET
desenha_botoes endp

;------------------------------------------------------------------------------
; desenha_botao: SI = botao, AL = 1 apertado / 0 normal (apagado = desativado)
;------------------------------------------------------------------------------
desenha_botao proc
        PUSH ax
        PUSH bx
        PUSH cx
        PUSH dx
        PUSH si
        MOV apertado,al
        CALL esconde_mouse

        MOV ax,[si+B_X]         ;limpa a area do botao
        MOV rx,ax
        MOV ax,[si+B_Y]
        MOV ry,ax
        MOV ax,[si+B_L]
        MOV rw,ax
        MOV ax,[si+B_A]
        MOV rh,ax
        MOV rcor,COR_FUNDO
        CALL retangulo

        MOV ax,[si+B_Y]         ;corpo: desce 2 pixels quando apertado
        CMP apertado,1
        JNE db_topo
        ADD ax,2
db_topo:
        MOV topo_b,ax
        MOV ry,ax
        MOV ax,[si+B_A]
        SUB ax,2
        MOV rh,ax
        MOV al,[si+B_COR]
        CMP apagado,1
        JNE db_ativo
        MOV al,COR_BTN_OFF
db_ativo:
        CMP apertado,1
        JNE db_cor
        MOV al,COR_APERTO
db_cor:
        MOV rcor,al
        CALL retangulo

        CMP apertado,1          ;sombra (so quando solto)
        JE  db_cantos
        MOV ax,[si+B_Y]
        ADD ax,[si+B_A]
        SUB ax,2
        MOV ry,ax
        MOV rh,2
        MOV al,[si+B_SOM]
        CMP apagado,1
        JNE db_sombra
        MOV al,COR_FUNDO
db_sombra:
        MOV rcor,al
        CALL retangulo

db_cantos:                      ;cantos arredondados
        MOV dl,COR_FUNDO
        MOV ax,[si+B_X]
        MOV bx,topo_b
        CALL pixel
        MOV cx,[si+B_Y]
        ADD cx,[si+B_A]
        DEC cx
        MOV bx,cx
        CALL pixel
        ADD ax,[si+B_L]
        DEC ax
        CALL pixel
        MOV bx,topo_b
        CALL pixel

        MOV al,[si+B_ESC]       ;rotulo centralizado
        MOV tesc,al
        MOV al,[si+B_CTXT]
        CMP apagado,1
        JNE db_txt
        MOV al,COR_APAGADO
db_txt:
        MOV tcor,al
        PUSH si
        MOV si,[si+B_ROT]
        CALL largura_texto
        POP si
        MOV bx,[si+B_L]
        SUB bx,ax
        SHR bx,1
        ADD bx,[si+B_X]
        MOV tx,bx
        MOV bx,[si+B_A]
        SUB bx,10               ;(altura do corpo - altura do texto) / 2
        CMP tesc,1
        JE  db_centro_y
        SUB bx,8
db_centro_y:
        SHR bx,1
        ADD bx,topo_b
        MOV ty,bx
        MOV si,[si+B_ROT]
        CALL desenha_texto

        CALL mostra_mouse
        POP si
        POP dx
        POP cx
        POP bx
        POP ax
        RET
desenha_botao endp

end main
