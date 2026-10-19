"""Testes automaticos do bin/SUDOKU.EXE.

Roda o programa num emulador 8086 (Unicorn) com DOS/BIOS/mouse simulados, joga
partidas inteiras clicando nas casas e nos botoes (ou pelo teclado) e confere o
resultado lendo a memoria de video, como se fosse uma pessoa olhando a tela.

Uso:  python3 testes/testa_sudoku.py        (requer: pip install unicorn pillow)
"""
import os, re, sys
AQUI = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, AQUI)
RAIZ = os.path.dirname(AQUI)
from dosemu import DOS

EXE = os.path.join(RAIZ, 'bin', 'SUDOKU.EXE')
SRC = open(os.path.join(RAIZ, 'Sudoku.asm')).read()

# cores do programa (indices da paleta)
COR_TEXTO, COR_JOGADOR, COR_ERRO = 39, 40, 42

# ---- jogos, lidos do proprio codigo-fonte ----
def jogo(nome):
    m = re.search(nome + r'\s+DB(.*?)(?=\n;|\n\n)', SRC, re.S)
    v = [int(x) for x in re.findall(r'\d', m.group(1))]
    assert len(v) == 81, nome
    return v
JOGOS = [(jogo(f'jogo{k}_p'), jogo(f'jogo{k}_s')) for k in range(1, 5)]

# ---- fonte, para reconhecer os numeros desenhados ----
FONTE = {}
for m in re.finditer(r'DB ((?:0[0-9A-F]{2}h,?){8})\s*;\s*(\d+)', open(os.path.join(RAIZ, 'fonte8x8.inc')).read()):
    FONTE[int(m.group(2))] = tuple(int(x[:-1], 16) for x in m.group(1).split(','))
GLIFO = {v: chr(k) for k, v in FONTE.items() if k < 127}

CEL_POS = [2, 23, 44, 66, 87, 108, 130, 151, 172]
TAB_X, TAB_Y = 4, 3

def tela(d):
    return bytes(d.mu.mem_read(0xA0000, 64000))

def le_glifo(fb, x, y, esc, cores):
    linhas, cor = [], None
    for r in range(8):
        v = 0
        for c in range(8):
            p = fb[(y + r * esc) * 320 + x + c * esc]
            bit = p in cores
            if bit: cor = p
            v = (v << 1) | bit
        linhas.append(v)
    return GLIFO.get(tuple(linhas)), cor

def tabuleiro(fb):
    """lista de 81 (digito ou 0, cor)"""
    out = []
    for l in range(9):
        for c in range(9):
            x, y = TAB_X + CEL_POS[c] + 2, TAB_Y + CEL_POS[l] + 2
            ch, cor = le_glifo(fb, x, y, 2, (COR_TEXTO, COR_JOGADOR, COR_ERRO))
            out.append((int(ch) if ch and ch.isdigit() else 0, cor))
    return out

def tem_texto(fb, s, x, y, esc, cor):
    for i, ch in enumerate(s):
        g, _ = le_glifo(fb, x + i * 8 * esc, y, esc, (cor,))
        if g != ch:
            return False
    return True

def no_painel(fb, s, y, esc, cor):
    larg = len(s) * 8 * esc
    return tem_texto(fb, s, 206 + (110 - larg) // 2, y, esc, cor)

def erros_na_tela(fb):
    return sum(fb[40 * 320 + 288 + 11 * k] == COR_ERRO for k in range(3))

# ---- entrada ----
def casa(l, c):
    return ('click', TAB_X + CEL_POS[c] + 10, TAB_Y + CEL_POS[l] + 10)

def numero(n):
    k = n - 1
    return ('click', 206 + 38 * (k % 3) + 17, 64 + 34 * (k // 3) + 15)

MENU = ('click', 260, 182)
def item_menu(k):            # k = 0..5
    return ('click', 160, 58 + 22 * k + 9)

def roda(eventos):
    d = DOS(EXE, eventos)
    st = d.run()
    return d, st

def jogada_completa(k):
    p, s = JOGOS[k]
    ev = [item_menu(k)]
    for i in range(81):
        if p[i] == 0:
            ev += [casa(i // 9, i % 9), numero(s[i])]
    return ev

falhas = 0
def confere(nome, ok, extra=''):
    global falhas
    falhas += not ok
    print(('ok    ' if ok else 'FALHA ') + nome + (f'  {extra}' if extra and not ok else ''))

if __name__ == '__main__':
    # 0) os jogos sao validos
    for k, (p, s) in enumerate(JOGOS):
        cons = all(p[i] in (0, s[i]) for i in range(81))
        linhas = all(sorted(s[r * 9:r * 9 + 9]) == list(range(1, 10)) for r in range(9))
        colunas = all(sorted(s[c::9]) == list(range(1, 10)) for c in range(9))
        quadros = all(sorted(s[(br + a) * 9 + bc + b] for a in range(3) for b in range(3)) == list(range(1, 10))
                      for br in (0, 3, 6) for bc in (0, 3, 6))
        confere(f'jogo {k + 1}: gabarito valido e coerente com o tabuleiro', cons and linhas and colunas and quadros)

    # 1) o tabuleiro inicial aparece certo
    for k, (p, s) in enumerate(JOGOS):
        d, st = roda([item_menu(k)])
        tb = tabuleiro(tela(d))
        ok = all(tb[i][0] == p[i] and (p[i] == 0 or tb[i][1] == COR_TEXTO) for i in range(81))
        confere(f'jogo {k + 1}: tabuleiro inicial desenhado corretamente', ok)

    # 2) partida completa pelo mouse em cada jogo -> vitoria
    for k in range(4):
        d, st = roda(jogada_completa(k))
        fb = tela(d)
        tb = tabuleiro(fb)
        p, s = JOGOS[k]
        cheio = all(tb[i][0] == s[i] for i in range(81))
        cores = all(tb[i][1] == (COR_TEXTO if p[i] else COR_JOGADOR) for i in range(81))
        venceu = no_painel(fb, 'VENCEU', 92, 2, 47)
        confere(f'jogo {k + 1}: partida completa pelo mouse termina em vitoria', cheio and cores and venceu and erros_na_tela(fb) == 0)
        if k == 0:
            d.framebuffer_png(os.path.join(AQUI, 'tela_vitoria.png'))

    # 3) o bug antigo: repetir o numero de uma casa que ja veio preenchida NAO vence
    p, s = JOGOS[0]
    d, st = roda([item_menu(0)] + [casa(0, 0), numero(5)] * 60)
    fb = tela(d)
    confere('repetir casa ja preenchida nao conta acerto nem erro',
            not no_painel(fb, 'VENCEU', 92, 2, 47) and erros_na_tela(fb) == 0 and tabuleiro(fb)[0] == (5, COR_TEXTO))

    # 4) tres erros -> derrota, com a resposta mostrada em vermelho
    vazia = p.index(0)
    errados = [n for n in range(1, 10) if n != s[vazia]][:3]
    ev = [item_menu(0), casa(vazia // 9, vazia % 9)] + [numero(n) for n in errados]
    d, st = roda(ev)
    fb = tela(d)
    tb = tabuleiro(fb)
    resposta = all(tb[i][0] == s[i] and tb[i][1] == (COR_TEXTO if p[i] else COR_ERRO) for i in range(81))
    confere('3 erros terminam em derrota e mostram o gabarito', no_painel(fb, 'PERDEU', 92, 2, COR_ERRO) and resposta and erros_na_tela(fb) == 3)
    d.framebuffer_png(os.path.join(AQUI, 'tela_derrota.png'))

    # 5) depois de perder, voltar ao menu e jogar de novo comeca do zero
    acerto = [casa(vazia // 9, vazia % 9), numero(s[vazia])]
    d, st = roda([item_menu(0)] + acerto + [numero(n) for n in errados][:0] +
                 [casa(0, 2)] + [numero(n) for n in range(1, 10) if n != s[2]][:3] + [MENU, item_menu(0)])
    fb = tela(d)
    tb = tabuleiro(fb)
    confere('jogar de novo reinicia o tabuleiro, os erros e o tempo',
            all(tb[i][0] == p[i] for i in range(81)) and erros_na_tela(fb) == 0)

    # 6) numero ja completo (as 9 casas) e ignorado, sem contar erro
    #    no jogo 1 completa todas as casas do numero 5 e tenta colocar 5 numa casa vazia
    ev = [item_menu(0)]
    for i in range(81):
        if p[i] == 0 and s[i] == 5:
            ev += [casa(i // 9, i % 9), numero(5)]
    outra = next(i for i in range(81) if p[i] == 0 and s[i] != 5)
    ev += [casa(outra // 9, outra % 9), numero(5)]
    d, st = roda(ev)
    fb = tela(d)
    confere('numero ja completo nao conta erro', erros_na_tela(fb) == 0 and tabuleiro(fb)[outra][0] == 0)

    # 7) partida completa so pelo teclado (setas + numeros) no jogo 4
    p4, s4 = JOGOS[3]
    ev = [('key', '4')]
    l, c = 4, 4
    SETAS = {'cima': 0x48, 'baixo': 0x50, 'esq': 0x4B, 'dir': 0x4D}
    for i in range(81):
        if p4[i]:
            continue
        tl, tc = divmod(i, 9)
        while l != tl:
            ev.append(('scan', 0, SETAS['baixo'] if tl > l else SETAS['cima'])); l += 1 if tl > l else -1
        while c != tc:
            ev.append(('scan', 0, SETAS['dir'] if tc > c else SETAS['esq'])); c += 1 if tc > c else -1
        ev.append(('key', str(s4[i])))
    d, st = roda(ev)
    fb = tela(d)
    confere('jogo 4 inteiro pelo teclado termina em vitoria',
            no_painel(fb, 'VENCEU', 92, 2, 47) and all(t[0] == v for t, v in zip(tabuleiro(fb), s4)))

    # 8) setas dao a volta no tabuleiro; clique na linha entre casas nao faz nada
    d, st = roda([('key', '1'), ('scan', 0, 0x48)] * 1 + [('scan', 0, 0x48)] * 4 + [('scan', 0, 0x4B)] * 5 +
                 [('key', '4')])      # vai de (4,4) para (8,8) dando a volta; (8,8) e 9 no jogo 1 -> ja preenchida
    confere('setas dao a volta nas bordas', erros_na_tela(tela(d)) == 0)

    # 9) ESC no jogo volta ao menu; ESC no menu sai do programa
    d, st = roda([('key', '2'), ('key', '\x1b'), ('key', '\x1b')])
    confere('ESC volta ao menu e ESC no menu encerra', st == 'exit' and d.exit_code == 0 and 'Obrigado' in d.text())

    # 10) tela de regras abre e volta
    d, st = roda([item_menu(4)])
    fb = tela(d)
    d.framebuffer_png(os.path.join(AQUI, 'tela_regras.png'))
    d2, st2 = roda([item_menu(4), ('key', ' '), item_menu(5)])
    confere('"Como jogar" abre, volta ao menu e "Sair" encerra', st2 == 'exit')

    print('falhas:', falhas)
    sys.exit(1 if falhas else 0)
