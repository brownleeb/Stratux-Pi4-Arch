# First, install clean copy of Arch Linux ARM v7 (ARMv7l)
pacman-key --init
pacman-key --populate archlinuxarm
sed -i 's/$/ audit=0 ipv6.disable=1/' /boot/cmdline.txt
pacman -Syu
pacman -S base-devel vim iw lshw wget gpsd tcpdump libusb cmake go mercurial autoconf fftw libtool automake pkg-config libjpeg python-pip python-pillow python-daemon screen sdl2 git rtl-sdr ncurses bladerf dnsmasq nginx go jq ifplugd usbutils lighttpd
echo -ne '{"DarkMode":false,"UAT_Enabled":true,"ES_Enabled":true,"OGN_Enabled":false,"APRS_Enabled":false,"AIS_Enabled":false,"Ping_Enabled":false,"GPS_Enabled":true,"BMP_Sensor_Enabled":false,"IMU_Sensor_Enabled":false,"NetworkOutputs":[{"Conn":null,"Ip":"","Port":4000,"Capability":5,"LastPingResponse":"0001-01-01T00:00:00Z","LastUnreachable":"0001-01-01T00:00:00Z","SleepFlag":false},{"Conn":null,"Ip":"","Port":2000,"Capability":8,"LastPingResponse":"0001-01-01T00:00:00Z","LastUnreachable":"0001-01-01T00:00:00Z","SleepFlag":false},{"Conn":null,"Ip":"","Port":49002,"Capability":18,"LastPingResponse":"0001-01-01T00:00:00Z","LastUnreachable":"0001-01-01T00:00:00Z","SleepFlag":false}],"SerialOutputs":null,"DisplayTrafficSource":false,"DEBUG":false,"ReplayLog":false,"AHRSLog":false,"PersistentLogging":false,"IMUMapping":[-1,0],"SensorQuaternion":[0,0,0,0],"C":[0,0,0],"D":[0,0,0],"PPM":0,"AltitudeOffset":0,"OwnshipModeS":"F00000","WatchList":"","DeveloperMode":true,"GLimits":"","StaticIps":[],"WiFiCountry":"US","WiFiSSID":"stratux","WiFiChannel":1,"WiFiSecurityEnabled":false,"WiFiPassphrase":"","NoSleep":false,"WiFiMode":0,"WiFiDirectPin":"","WiFiIPAddress":"192.168.10.1","WiFiClientNetworks":[{"SSID":"","Password":""}],"WiFiInternetPassThroughEnabled":false,"EstimateBearinglessDist":false,"RadarLimits":10000,"RadarRange":10,"OGNI2CTXEnabled":false,"OGNAddr":"","OGNAddrType":0,"OGNAcftType":0,"OGNPilot":"","OGNReg":"","OGNTxPower":0,"PWMDutyMin":0}' > /boot/stratux.conf
useradd -d /home/pi -U -m pi
mkdir /opt/stratux
chown pi:pi /opt/stratux
passwd pi
cd /root
rm -rf /root/kalibrate-rtl
git clone https://github.com/steve-m/kalibrate-rtl
cd kalibrate-rtl
./bootstrap && CXXFLAGS='-W -Wall -O3'
./configure
make -j8 && make install
rm -rf /root/kalibrate-rtl

# clone stratux
cd /root
rm -r /root/stratux
git clone --recursive https://github.com/VirusPilot/stratux.git /root/stratux
cd /root/stratux/image
sed "/i2c/d" config.txt  > /boot/config.txt
sed -i "/arm_64bit=1/d" /boot/config.txt
sed "/GOROOT/d" bashrc.txt > /root/.bashrc
cp -f rc.local /etc/rc.local
cp -f modules.txt /etc/modules
cp -f motd /etc/motd
cp -f logrotate.conf /etc/logrotate.conf
cp -f logrotate_d_stratux /etc/logrotate.d/stratux
cp -f rtl-sdr-blacklist.conf /etc/modprobe.d/
cp -f stxAliases.txt /root/.stxAliases
cp -f stratux-dnsmasq.conf /etc/dnsmasq.conf
echo -e "no-poll\nno-resolv\nserver=1.1.1.1" >> /etc/dnsmasq.conf
cp -f wpa_supplicant_ap.conf /etc/wpa_supplicant/wpa_supplicant-wlan0.conf
mkdir -p /etc/network && cp -f interfaces /etc/network/interfaces
cp -f sshd_config /etc/ssh/sshd_config

sed -i "/server.document-root/d" /etc/lighttpd/lighttpd.conf
echo -e 'server.stat-cache-engine = "disable"\nserver.document-root = /opt/stratux/www' >> /etc/lighttpd/lighttpd.conf
echo 'stratux' > /etc/hostname
echo -e "[Match]\nName=wlan0\n\n[Network]\nAddress=192.168.10.1/24\nDNSSEC=no" > /etc/systemd/network/wlan0.network


# prepare services
#systemctl enable sshd
systemctl enable lighttpd
systemctl enable fancontrol
#systemctl disable dnsmasq # we start it manually on respective interfaces
systemctl enable dnsmasq
systemctl disable dhcpcd
#systemctl disable wpa_supplicant
systemctl enable wpa_supplicant@wlan0
systemctl enable systemd-networkd
systemctl disable systemd-timesyncd
systemctl enable stratux

source /root/.bashrc
cd /root/stratux
sed -i "s/ARCH=$(shell arch)/ARCH=$(shell uname -m)/" Makefile
make
make install

