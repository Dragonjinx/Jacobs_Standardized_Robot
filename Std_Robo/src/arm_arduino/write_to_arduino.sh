sudo apt-get update
sudo apt-get install arduino-mk
cd ~
mkdir sketchbook
cd //usr/share/arduino/libraries
cp ~/catkin_ws/src/sr_pkg/Std_Robo/src/arm_arduino/Servo.h //usr/share/arduino/libraries 
cp ~/catkin_ws/src/sr_pkg/Std_Robo/src/arm_arduino/arm_arduino.ino ~/sketchbook
cp ~/catkin_ws/src/sr_pkg/Std_Robo/src/arm_arduino/Makefile ~/sketchbook
cd ~/sketchbook
mkdir libraries
make
make upload clean
