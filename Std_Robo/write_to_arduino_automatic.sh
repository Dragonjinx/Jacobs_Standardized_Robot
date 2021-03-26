#!/bin/bash
cd ~
mkdir sketchbook
cp ~/catkin_ws/src/sr_pkg/src/arm_arduino/arm_arduino.ino ~/sketchbook
cp ~/catkin_ws/src/sr_pkg/src/arm_arduino/Makefile ~/sketchbook
cd ~/sketchbook
mkdir libraries
make PORT= /dev/serial/by-id/*Arduino*
make upload clean;