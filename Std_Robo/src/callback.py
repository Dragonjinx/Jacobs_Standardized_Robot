#!/usr/bin/env python3
import rospy
from geometry_msgs.msg import Pose
from sympy import *
import numpy as np
from std_msgs.msg import String
import time,random

def callback(target):

    final_string = ("This is a default string given by your rosnode" +\
        "\nYour X: " + str(target.position.x) + \
        "\nYour Y: " + str(target.position.y) + \
        "\nYour Z: " + str(target.position.z))

    rospy.loginfo(final_string)
    serial_pub.publish(final_string)

rospy.init_node('callback')
serial_pub=rospy.Publisher('serial_commands', String, queue_size=5)
reverse_sub=rospy.Subscriber('pose', Pose, callback=callback)

while True:
    rospy.spin()