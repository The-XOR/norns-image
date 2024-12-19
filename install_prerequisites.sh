curl https://keybase.io/artfwo/pgp_keys.asc | sudo apt-key add -
apt update

apt-get install -y vim git bc i2c-tools

apt-get install -y libevdev-dev liblo-dev libudev-dev libcairo2-dev liblua5.3-dev libavahi-compat-libdnssd-dev
apt-get install -y libasound2-dev libncurses5-dev libncursesw5-dev libsndfile1-dev
apt-get install gpiod libgpiod-dev libgpiod-doc 

apt-get install -y luarocks liblua5.1-dev
luarocks install -y ldoc

apt-get install -y mc
apt-get install -y --no-install-recommends jackd2 libjack-jackd2-dev
apt-get install -y --no-install-recommends libmonome-dev libnanomsg-dev supercollider-language supercollider-server supercollider-dev
apt-get install -y --no-install-recommends libboost-dev dnsmasq
apt-get install -y --no-install-recommends sc3-plugins
apt-get install -y --no-install-recommends ladspalist 
apt-get install -y usbmount
apt-get install -y network-manager

# ripristina wifi
systemctl disable dhcpcd
systemctl stop dhcpcd
sudo cp --remove-destination config/NetworkManager.conf /etc/NetworkManager/NetworkManager.conf
