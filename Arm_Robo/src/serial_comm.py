#!/usr/bin/env python3
import rospy
import serial
from std_msgs.msg import String

ser = serial.Serial('/dev/tty*', baudrate=9600, timeout=1)
ser.flush()

def callback(message):
    ser.write(str(message).encode('utf-8'))

rospy.init_node('serial_messenger')
rospy.Subscriber('serial_commands',String, callback=callback)

while True:
    rospy.spin()