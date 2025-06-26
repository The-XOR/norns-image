# BUILD

* download raspbian lite image: https://www.raspberrypi.org/downloads/raspbian/

The remaining commands happen within the terminal session:
login is "pi" with password "raspberry"

* `sudo raspi-config`

1. Change password: sleep
2. Network > Hostname (norns)
3. Network > Wifi (set SSID/password)
4. Interfacing > SSH (on)
5. Interfacing > SPI on
6. Localization > timezone, keyboard (US layout), 
7. Exit, Reboot

relogin (attenzione: ora la password è sleep)
1. sudo apt-get update
2. sudo apt-get upgrade
3. sudo reboot

* change user name: we

1  `sudo passwd root`  --> cambiare la password in "root" (!)
2. logout, login as root
3. `usermod -l we -d /home/we -m pi`
4. `groupmod --new-name we pi`
5. exit, login as we
6. `sudo passwd -l root`

disable need for passwd with sudo:

1. sudo nano /etc/sudoers.d/010_pi-nopasswd
2. change 'pi' to 'we'

* Installare i prerequisiti:

--- OCIO: LA PROSSIMA LINEA E' PER 'BUSTER', MA NEL CASO FOSSE AGGIORNATO RASPIOS AD UNA FUTURA VERSIONE AGGIORNARE DI CONSEGUENZA
echo "deb https://package.monome.org/ buster main" | sudo tee /etc/apt/sources.list.d/norns.list

sudo ./install_prerequisites.sh

reboot!!!!!

Ripristinare wifi:

nmcli device wifi con "Nome rete wifi" password "password rete wifi"

*****************************************

Inserire nello slotto usbo la sound card che si intende  utilizzare (per es la cara vecchia barbonger uca222)
aplay -l
Si ottiene  un output tipo questo:

**** List of PLAYBACK Hardware Devices ****
card 1: CODEC [USB Audio CODEC], device 0: USB Audio [USB Audio]
  Subdevices: 1/1
  Subdevice #0: subdevice #0

quindi, aplay -L
....
ull
    Discard all samples (playback) or generate zero samples (capture)
default
    Default Audio Device
sysdefault
    Default Audio Device
hw:CARD=CODEC,DEV=0
    USB Audio CODEC, USB Audio
    Direct hardware device without any conversions
plughw:CARD=CODEC,DEV=0


annotarsi il n. di card della scheda che si vuole utilizzare

git clone https://github.com/The-XOR/norns.git --depth=1
git clone https://github.com/The-XOR/norns-image.git --depth=1
cd norns-image
git submodule init
cd norns-image/config
nano asound.conf
inserire qui il numero di card annotato in precedenza (per default, 1)

nano jackdrc
cambiare il parametro -dhw:CARD=...DEV=...  utilizzando il # di card desiderato (per default: CARD=CODEC,DEV=0)

nano norns-jack.service
riga ExecStart=... cambiare il parametro -dhw:XXX  utilizzando il # di card desiderato (per default, 1)

---- Compilazione norns:
Prima di compilare occore svagare quale framebuffer occorre utilizzare.
Ammesso che il display sia connesso e sia stato riconosciuto dal sistema operativo, col comando
dmesg | grep "frame buffer"
otteniamo un output simile a:

    1.973588] Console: switching to colour frame buffer device 80x30
[   10.282509] graphics fb1: fb_st7735r frame buffer, 160x128, 40 KiB video memory, 4 KiB buffer memory, fps=50, spi0.0 at 40 MHz

Quindi il ns display (nell'es qui sopra fb_st7735r) sta usando il framebuffer 1 (fb1).

Apriamo quindi con decisione il file ~/norns/matron/src/args.c e modifichiamo la linea:

static struct args a = {
    .loc_port = "8888",
    .ext_port = "57120",
    .crone_port = "9999",
    .framebuffer = "/dev/fb0",  <------------- FRAME BUFFER
};

Ora -e solo ora- possiamo compilare.

cd norns
git submodule update --init --recursive
./waf configure
./waf

Eseguire ./sclang.sh per controllare che supercollider si avvii correttamente.
Dopo lunghe peripezie, la linea di comando originale NON funzionava dopo le ultime modifiche. Ho visto che si poteva
avviare aggiungendo la variabile QT_QPA_PLATFORM prima di eseguire il comando, ma comunque SuperCollider e' sempre
un punto di domanda ed un domani potrebbe di nuovo non funzionare. Qusto comando (sclang.sh) viene eseguito allo start
dal servizio /etc/systemd/system/norns-sclang.service.
---> L'avvio di questo comando creera' la cartella /home/we/.local/share/SuperCollider/Extensions che ci serve per continuare
con l'installazione!

Uscire con Ctrl+D
cd sc
./install.sh

crea documentazizone
cd ~/norns
ldoc .

cd ~/norns-image
./setup.sh

--- Installazione maiden:
- scaricare ultima versione di maiden da https://github.com/monome/maiden/releases.
va installato in ~/
per es. wget https://github.com/monome/maiden/releases/download/v1.1.5/maiden-v1.1.5.tgz
tar -xzvf maiden-v1.1.5.tgz
rm maiden-v1.1.5.tgz



--- Installazione ttymidi:
cd
sudo apt-get install libasound2-dev
wget http://www.varal.org/ttymidi/ttymidi.tar.gz
tar -zxvf ttymidi.tar.gz
cd ttymidi
Editare Makefile ed aggiungere
    -lpthread 
in "all:"
    gcc src/ttymidi.c -o ttymidi -lasound -lpthread
quindi
make
sudo make install

A questo punto dobbiamo creare le porte midi raw, quelle effettivamente usate da norns (ttymidi crea delle porte "sequencer").
Per procedere:
sudo modprobe snd-virmidi
amidi -l
Dovremmo vedere, se tutto funziona, un elenco di porte Raw, tipo:
Dir Device    Name
IO  hw:0,0    Virtual Raw MIDI (16 subdevices)
IO  hw:0,1    Virtual Raw MIDI (16 subdevices)
IO  hw:0,2    Virtual Raw MIDI (16 subdevices)
IO  hw:0,3    Virtual Raw MIDI (16 subdevices)

Se cosi' e', rendiamo PERMANENTE il comando con:
echo "snd-virmidi" | sudo tee -a /etc/modules

Ci penseranno poi i servizi topici ttymidi e midiconnect (appositamente creati dal sempervoster) a connettere
la porta midi sequencer con quella virtuale, utilizzabile da norns.

Per ultimo... dust!
il file dust.tar (che viene scompattato automatricamente da setup.sh) e' stato generato scaricando l'immagine di norns
(https://github.com/monome/norns-image/releases) e generando un file tar della directory dust.

reboot, norns should boot up.

set up `usbmount` for SYNC/etc via menu:

   (1) the 'usbmount' package is installed
       apt-get install usbmount

   (2) MountFlags has been tweaked in systemd-udevd.service (da:        https://www.raspberrypi.org/forums/viewtopic.php?t=205016)

   sudo nano /lib/systemd/system/systemd-udevd.service
       change MountFlags=slave to MountFlags=shared

    reboot

# AUDIO USB:
# MODIFICARE QUESTO FILE e mettere il numero di scheda audio voluta
aplay -l | grep "USB Audio"|awk  '{print "default.pcm.card " substr($2,1,1) "\ndefault.ctl.card " substr($2,1,1)}' | sudo tee /etc/asound.conf


DEBUG
Per riabilitare l'uscita HDMI, selezionare nel file cmdline.txt la linea "#DEBUG"
La password per l'utente we e' "sleep"
Per connettersi alla internet, utilizzare la LAN
