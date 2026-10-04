#!/usr/bin/env python3
"""Troca os icones embutidos do LiveOS pelos seus (ex.: logos oficiais).

Como usar (no PC, com internet):
  1. Baixe cada logo e salve na pasta tools/icons/ com o ID do app como nome:
       netflix.svg  youtube.png  prime.svg  disney.svg  globoplay.png  max.svg ...
     (aceita .svg .png .webp .jpg). IDs: netflix youtube prime disney globoplay max
     crunchyroll spotify twitch xbox apple paramount pluto looke mubi plex ytmusic
     deezer soundcloud geforce cazetv espn dazn tiktok
     Dica: dashboardicons.com tem varios; use fundo transparente.
  2. Rode:  python3 tools/embed-icons.py
  3. Gere o SD de novo (./build.sh).
O icone aparece sobre a cor do bloco, entao prefira logos brancos ou com fundo transparente.
"""
import base64, glob, json, os, re, sys
AQUI = os.path.dirname(os.path.abspath(__file__))
HTML = os.path.join(AQUI, '..', 'external', 'board', 'liveos', 'overlay', 'usr', 'share', 'liveos', 'liveos.html')
MIME = {'.svg': 'image/svg+xml', '.png': 'image/png', '.webp': 'image/webp', '.jpg': 'image/jpeg', '.jpeg': 'image/jpeg'}

s = open(HTML, encoding='utf-8').read()
m = re.search(r'/\*ICONS_BEGIN\*/\s*var ICONS=(\{.*?\});\s*/\*ICONS_END\*/', s, re.S)
if not m:
    sys.exit('Marcadores ICONS_BEGIN/ICONS_END nao encontrados no liveos.html')
icons = json.loads(m.group(1))
n = 0
for f in sorted(glob.glob(os.path.join(AQUI, 'icons', '*'))):
    ext = os.path.splitext(f)[1].lower()
    ident = os.path.splitext(os.path.basename(f))[0].lower()
    if ext not in MIME:
        continue
    icons[ident] = 'data:%s;base64,%s' % (MIME[ext], base64.b64encode(open(f, 'rb').read()).decode())
    n += 1
    print('ok', ident)
new = '/*ICONS_BEGIN*/\nvar ICONS=' + json.dumps(icons, indent=0) + ';\n/*ICONS_END*/'
s = s[:m.start()] + new + s[m.end():]
open(HTML, 'w', encoding='utf-8').write(s)
print(n, 'icone(s) trocado(s).')
