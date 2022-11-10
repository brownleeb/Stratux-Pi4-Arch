# Stratux-Pi4-Arch

Being a fan of Arch Linux, I decided to take a shot at creating an install script, based on VirusPilot's scripts (https://github.com/VirusPilot/stratux-pi4).

A couple of limitations:
   - This is for installs WITHOUT AHRS sensor.  I2C drivers are disabled, wiringPi is not installed
   - The system boots up with wifi in AP mode (192.168.10.1).  AP+client needs work.
   - Contains some fixes I prefer, such as not mounting /dev/sda (caused a delay in boot).
   - SDR Gain for both was set to about 25.  In limited testing, this still picks up aircraft up to 10 miles away, but not sure about ADS-B ground statioins.  Needs inflight testing
