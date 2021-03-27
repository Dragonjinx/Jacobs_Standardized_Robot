#!/bin/bash

while getopts ":d:" opt; do
    case "${opt}" in
        d) ard_port=${OPTARG} ;;
        *) echo "Please use the -d tag to pass through arduino port" ;;
    esac
done

if [ "${ard_port}" ]; then
    echo "Uploading code to device at ${ard_port}";
    cd ~
    mkdir sketchbook
    cp ~/catkin_ws/src/sr_pkg/src/arm_arduino/arm_arduino.ino ~/sketchbook
    cp ~/catkin_ws/src/sr_pkg/src/arm_arduino/Makefile ~/sketchbook
    cd ~/sketchbook
    mkdir libraries
    make PORT= "$ard_port";
    make upload clean;
    exit 0
fi
echo "Please use the -d tag to pass through arduino port"
