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
6. Localization > timezone, keyboard, 
7. Exit, Reboot

relogin (attenzione: ora la password è sleep)
* sudo apt-get update
* sudo apt-get upgrade
* sudo reboot
* sudo apt-get install vim git bc i2c-tools

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

sudo apt-get install libevdev-dev liblo-dev libudev-dev libcairo2-dev liblua5.3-dev libavahi-compat-libdnssd-dev libasound2-dev libncurses5-dev libncursesw5-dev libsndfile1-dev

sudo apt-get install network-manager

sudo apt-get install luarocks liblua5.1-dev
sudo luarocks install ldoc

sudo apt-get install mc (non un prerequisito, ma come non averlo?)

curl https://keybase.io/artfwo/pgp_keys.asc | sudo apt-key add -

--- OCIO: LA PROSSIMA LINEA E' PER 'BUSTER', MA NEL CSO FOSSE AGGIORNATO RASPIOS AD UNA FUTURA VERSIONE AGGIORNARE DI CONSEGUENZA
echo "deb https://package.monome.org/ buster main" | sudo tee /etc/apt/sources.list.d/norns.list

sudo apt update
sudo apt install --no-install-recommends jackd2 libjack-jackd2-dev
sudo apt install --no-install-recommends libmonome-dev libnanomsg-dev supercollider-language supercollider-server supercollider-dev
sudo apt install --no-install-recommends libboost-dev dnsmasq
sudo apt install --no-install-recommends sc3-plugins
sudo apt install --no-install-recommends ladspalist usbmount


sudo nano /boot/config.txt
# Enable audio (loads snd_bcm2835)
dtparam=audio=off  <-----------  impostare ad OFF l'audio interno del raspoberro
reboot!!!!!

Inserire nello slotto usbo la sound card che si intende  utilizzare (per es la cara vecchia barbonger uca222)
aplay -l
Si ottiene  un output tipo questo:

**** List of PLAYBACK Hardware Devices ****
card 1: CODEC [USB Audio CODEC], device 0: USB Audio [USB Audio]
  Subdevices: 1/1
  Subdevice #0: subdevice #0

annotarsi il n. di card della scheda che si vuole utilizzare

git clone https://github.com/The-XOR/norns.git --depth=1
git clone https://github.com/The-XOR/norns-image.git --depth=1
cd norns-image/config
nano asound.conf
inserire qui il numero di card annotato in precedenza (per default, 1)

nano jackdrc
cambiare il parametro -dhw:XXX  utilizzando il # di card desiderato (per default, 1)

nano norns-jack.service
riga ExecStart=... cambiare il parametro -dhw:XXX  utilizzando il # di card desiderato (per default, 1)

---- Compilazione norns:
cd norns
git submodule update --init --recursive
./waf configure
./waf
sclang [bisogna lanciare almeno la prima volta supercollider, oppure crearsi il folder a mano]
Uscire con Ctrl+D
cd sc
./install.sh

crea documentazizone
cd ~/norns
ldoc .

cd ~/norns-image
./setup.sh

lanciare alsamixer
Selezionare la scheda audio che si intende utilizzare e settarla alla stecca della manetta

--- Installazione maiden:
- scaricare ultima versione di maiden da https://github.com/monome/maiden/releases.
va installato in ~/
per es. wget https://github.com/monome/maiden/releases/download/v1.1.2/maiden-v1.1.2.tgz
tar -xzvf maiden-v1.1.2.tgz
rm maiden-v1.1.2.tgz


reboot, norns should boot up.

set up `usbmount` for SYNC/etc via menu:

   (1) the 'usbmount' package is installed
       apt-get install usbmount

   (2) MountFlags has been tweaked in systemd-udevd.service
       https://www.raspberrypi.org/forums/viewtopic.php?t=205016
       (change MountFlags=slave to MountFlags=shared)
