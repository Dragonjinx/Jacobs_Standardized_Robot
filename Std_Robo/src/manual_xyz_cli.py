#!/usr/bin/env python3
import rospy
from geometry_msgs.msg import Pose
import sys

rospy.init_node("manual_gui")
xyz_pub=rospy.Publisher('pose', Pose, queue_size=1)

while 1:
    x=input()
    y=input()
    z=input()
    target=Pose()
    target.position.x=self.x
    target.position.y=self.y
    target.position.z=self.z
    xyz_pub.publish(target)
