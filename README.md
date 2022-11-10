# Stratux-Pi4-Arch

Being a fan of Arch Linux, I decided to take a shot at creating an install script, based on VirusPilot's scripts (https://github.com/VirusPilot/stratux-pi4).

A couple of limitations:
   - This is for installs WITHOUT AHRS sensor.  I2C drivers are disabled, wiringPi is not installed
   - The system boots up with wifi in AP mode (192.168.10.1).  AP+client needs work.
