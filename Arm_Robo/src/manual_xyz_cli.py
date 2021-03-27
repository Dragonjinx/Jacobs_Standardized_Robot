#!/usr/bin/env python3
import rospy
from geometry_msgs.msg import Pose
import sys, time

rospy.init_node("manual_gui")
xyz_pub=rospy.Publisher('pose', Pose, queue_size=1)

while 1:
    time.sleep(5)
    x=input("target x:")
    y=input("target y:")
    z=input("target z:")
    target=Pose()
    target.position.x=float(x)
    target.position.y=float(y)
    target.position.z=float(z)
    xyz_pub.publish(target)
