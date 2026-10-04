# LiveOS para GameStick RK3066 (sem Android)

Sistema Linux mínimo que liga direto na interface LiveOS: só entretenimento
(YouTube, Netflix, Prime Video, Disney+, Globoplay, Max, Spotify, Twitch, Xbox Cloud…),
com **Standby** (paisagens por horário + relógio, data, clima) e **Wi-Fi automático**.
Liga direto na tela inicial (sem animação de boot) e não tem botão Desligar nem Modo quadro.

> **Status: NÃO TESTADO na placa.** O código foi escrito e revisado, mas ninguém
> compilou nem ligou isso num RK3066 ainda. Espere ajustes no primeiro boot.

## Como o RK3066 liga (importante)

A ROM de boot do RK3066 **não lê cartão SD** (confirmado na documentação do U-Boot).
Por isso são **dois** passos de gravação:

1. **Carregador na NAND da stick** (`RK30xxLoader_uboot.bin`), gravado por cabo USB. É só uma vez.
2. **Cartão SD** (`sdcard.img`) com o U-Boot completo, o kernel e o sistema.

Com os dois, a stick liga: NAND chama o SD, o SD sobe o Linux.

## Passo a passo no Windows

### A. Gerar os arquivos (WSL2)
Precisa de ~60 GB livres, 8 GB de RAM e algumas horas.
1. PowerShell como administrador: `wsl --install -d Ubuntu`, reinicie e crie usuário/senha.
2. Copie este zip para dentro do Ubuntu (ex.: `cp /mnt/c/Users/SEU_USUARIO/Downloads/liveos-system.zip ~`) e rode `unzip liveos-system.zip -d liveos && cd liveos`.
3. Instale as dependências (comando no topo do `build.sh`) e rode `./build.sh`.
4. No fim, a pasta `saida` tem `sdcard.img` e `RK30xxLoader_uboot.bin`. Copie para o Windows.

### A'. Alternativa sem WSL: compilar na nuvem (GitHub Actions)
Para notebook fraco. O build roda nos servidores do GitHub; o notebook só baixa o resultado.
1. Crie uma conta e um repositório **público** (runners gratuitos de 4 núcleos só em repositório público).
2. Descompacte o zip no notebook e arraste **todo o conteúdo** (incluindo a pasta `.github`) para o repositório (Add file > Upload files).
3. Aba **Actions** > "Gerar LiveOS" > **Run workflow**.
4. Se parar em ~5h20 como "incompleto", clique em **Re-run all jobs**: ele continua de onde parou (cache).
5. No fim, baixe o artefato `liveos-arquivos` (contém `sdcard.img.xz` e `RK30xxLoader_uboot.bin`).
   O balenaEtcher grava o `.xz` direto, sem descompactar.

### B. Gravar o SD
1. Instale o **balenaEtcher**, escolha `sdcard.img` e o cartão (4 GB ou mais) e grave.
2. Se o Windows pedir para formatar discos, **não formate**.
3. Abra a partição pequena e edite `liveos-wifi.txt` com sua rede e senha.

### C. Gravar o carregador na stick (USB)
Ferramentas Rockchip para Windows: **DriverAssistant** (driver) e **RKDevTool**
(a Radxa distribui as duas na documentação dela). Não confirmei a versão que serve
melhor para o RK3066.
1. Instale o driver (DriverInstall.exe, botão Install Driver).
2. Ligue a stick ao notebook pelo cabo na porta **mini-USB OTG**, sem o SD.
3. Abra o RKDevTool. Deve aparecer "Found One MASKROM Device".
   - Se não aparecer e a NAND tiver algo gravado, é preciso curto-circuitar pinos da NAND
     (a doc do U-Boot cita os pinos 8 e 9 do chip) ao conectar. Faça só se for preciso.
4. Escolha o `RK30xxLoader_uboot.bin` como Loader e grave (equivale ao comando
   `upgrade_tool ul RK30xxLoader_uboot.bin` da doc).
5. Desconecte, coloque o SD, ligue na TV.

## O que cada parte faz

| Peça | Onde |
|---|---|
| Interface (a que você usa na TV) | `external/board/liveos/overlay/usr/share/liveos/liveos.html` |
| Liga o Wi-Fi no boot, pega IP, acerta a hora | `overlay/etc/init.d/S40wifi` |
| Sobe servidor local + navegador em tela cheia | `overlay/etc/init.d/S90liveos`, `usr/bin/liveos-kiosk` |
| Wi-Fi/reiniciar pela interface | `overlay/usr/share/liveos/cgi-bin/*` |
| Tecla Home (volta do Netflix/YouTube) | `overlay/etc/triggerhappy/triggers.d/liveos.conf` |
| Kernel, U-Boot, pacotes, imagem do SD | `external/configs/liveos_rk3066_defconfig`, `linux.fragment`, `genimage.cfg` |

A interface pode ser aberta no PC (duplo clique no `liveos.html`) só para ver o visual.
Wi-Fi, reiniciar e sistema só funcionam dentro da stick.

## Limites que você precisa saber

- **Netflix, Prime Video, Disney+ e Max usam DRM (Widevine).** O navegador desta imagem
  não tem Widevine, então esses quatro provavelmente **abrem mas não tocam vídeo**.
  YouTube, Twitch, Spotify (web) e sites sem DRM devem funcionar.
- **Sem decodificação de vídeo por hardware.** O decodificador de vídeo do RK3066 não tem
  driver no Linux atual. O vídeo roda pelo processador (2 núcleos): 720p aguenta,
  1080p e VP9 do YouTube tendem a travar.
- **A GPU (Mali-400) depende do driver Lima** e de a placa ter o nó da GPU no device tree.
  Se o navegador não abrir, é o primeiro suspeito.
- **Wi-Fi depende do chip da sua stick.** O kernel inclui Realtek (RTL8188/8192), Atheros
  AR9271, MediaTek MT7601 e Broadcom SDIO. Se não achar adaptador, rode `lsusb` e
  `dmesg | grep -i -E "usb|wlan|firmware"` pelo console serial e me mande a saída.
- O device tree usado é o do **MK808** (outra stick RK3066). Pode faltar ajuste de
  memória, HDMI ou Wi-Fi para o seu modelo (X1 Plus).
- O carregador da NAND usa blobs de memória do repositório `rkbin` da Rockchip, baixados
  pelo build. Se o `make-nand-loader.sh` não achar os arquivos, o repositório mudou.
- A memória (DDR) do carregador é a do MK808. Se sua stick usa outro chip de RAM, pode não iniciar.
- Dá para ver o boot por uma saída serial (UART2, 115200 baud) abrindo a stick.

## Controle

Setas, OK, Esc/Voltar e Home em teclado, mouse aéreo ou controle USB (direcional + A/B).
Senha do Wi-Fi: teclado na tela navegável pelo controle (ou teclado USB).
O terminal local usa o usuário `root`, senha `liveos` (troque no defconfig).

## Ícones e abertura de apps

- Os ícones dos blocos são **desenhos próprios embutidos em base64** no `liveos.html`
  (funcionam sem internet). Não são os logos oficiais. Para usar os oficiais, veja
  `tools/embed-icons.py` (lê `tools/icons/<id>.svg|png` e reembute).
- Ao abrir um app (YouTube, Netflix...), o bloco cresce até a tela cheia com a rodinha.
  O sistema testa a conexão com o site: se falhar (ou passar de 12 s), mostra
  "Erro de conexão — verifique a Internet" com *Tentar de novo* e *Voltar*.
  Se conectar, o navegador troca para o app, com a rodinha ainda na tela até o site aparecer.
