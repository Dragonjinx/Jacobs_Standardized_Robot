#!/usr/bin/env python3
import rospy
from geometry_msgs.msg import Pose
from sympy import *
import numpy as np
import serial

ser = serial.Serial('/dev/ttyUSB0', baudrate=9600, timeout=1)
ser.flush()

def Jrotz(theta):
    M=Matrix([[cos(theta), -1*sin(theta), 0, 0], [sin(theta), cos(theta), 0, 0], [0,0,1,0], [0,0,0,1]])
    return M
def Jroty(theta):
    M=Matrix([[cos(theta), 0, sin(theta), 0],[0,1,0,0], [-1*sin(theta), 0, cos(theta), 0],[0,0,0,1]])
    return M
def Jtransz(l):
    M=Matrix([[1,0,0,0], [0,1,0,0], [0,0,1,l], [0,0,0,1]])
    return M
def Jtransx(l):
    M=Matrix([[1,0,0,l], [0,1,0,0], [0,0,1,0], [0,0,0,1]])
    return M

def rotz(theta):
    M=np.array([[np.cos(theta), -1*np.sin(theta), 0, 0], [np.sin(theta), np.cos(theta), 0, 0], [0,0,1,0], [0,0,0,1]])
    return M
def roty(theta):
    M=np.array([[np.cos(theta), 0, np.sin(theta), 0],[0,1,0,0], [-1*np.sin(theta), 0, np.cos(theta), 0],[0,0,0,1]])
    return M
def transz(l):
    M=np.array([[1,0,0,0], [0,1,0,0], [0,0,1,l], [0,0,0,1]])
    return M
def transx(l):
    M=np.array([[1,0,0,l], [0,1,0,0], [0,0,1,0], [0,0,0,1]])
    return M

def forward(q):
    link1, link2, link3, link4, link5, link6=transz(q[0]), transz(q[1]), transz(q[2]), transz(q[3]), transx(q[4]), transz(q[5])
    joint1, joint2, joint3, joint4, joint5=rotz(q[6]), roty(q[7]), roty(q[8]), roty(q[9]), rotz(q[10])
    M=link1@joint1@link2@joint2@link3@joint3@link4@joint4@link5@joint5@link6
    M=M@np.array([[0],[0],[0],[1]])
    M=M[:-1,:]
    return M


def inverse(target_x, target_y, target_z):
    l1, l2, l3, l4, l5, l6, r1, r2, r3, r4, r5 = symbols('l1 l2 l3 l4 l5 l6 r1 r2 r3 r4 r5')
    link1, link2, link3, link4, link5, link6=Jtransz(l1), Jtransz(l2), Jtransz(l3), Jtransz(l4), Jtransx(l5), Jtransz(l6)
    joint1, joint2, joint3, joint4, joint5=Jrotz(r1), Jroty(r2), Jroty(r3), Jroty(r4), Jrotz(r5)
    M=Matrix(link1*joint1*link2*joint2*link3*joint3*link4*joint4*link5*joint5*link6)
    #M=M.subs([(cos, np.cos), (sin, np.sin), (l1, 6), (l2,6), (l3, 10), (l4,10), (l5,-3), (l6,15), (r1,0), (r2,0), (r3,0), (r4,0), (r5,0)] )
    position = M * Matrix([0,0,0,1])
    x=position[0]
    y=position[1]
    z=position[2]
    xdiffr1=diff(x, r1)
    xdiffr2=diff(x, r2)
    xdiffr3=diff(x, r3)
    xdiffr4=diff(x, r4)
    xdiffr5=diff(x, r5)

    ydiffr1=diff(y, r1)
    ydiffr2=diff(y, r2)
    ydiffr3=diff(y, r3)
    ydiffr4=diff(y, r4)
    ydiffr5=diff(y, r5)


    zdiffr1=diff(z, r1)
    zdiffr2=diff(z, r2)
    zdiffr3=diff(z, r3)
    zdiffr4=diff(z, r4)
    zdiffr5=diff(z, r5)

    l_1=6#on z
    r_1=0#around z
    l_2=6#on z
    r_2=0# around y
    l_3=10#on z
    r_3=0#around y
    l_4=10#on z
    r_4=0#around y
    l_5=-3#on x
    r_5=0#around z
    l_6=15# on z

    Jacobian=Matrix([[xdiffr1, xdiffr2, xdiffr3, xdiffr4, xdiffr5], [ydiffr1, ydiffr2, ydiffr3, ydiffr4, ydiffr5], [zdiffr1, zdiffr2, zdiffr3, zdiffr4, zdiffr5]])
    Jt=Jacobian.T
    Jt_subbed=Jt.subs([(cos, np.cos), (sin, np.sin), (l1, l_1), (l2,l_2), (l3, l_3), (l4,l_4), (l5,l_5), (l6,l_6), (r1,0), (r2,0), (r3,0), (r4,0), (r5,0)] )

    #target_x=15
    #target_y=10
    #target_z=30

    target=np.array([[target_x], [target_y], [target_z]])

    F_q=forward(np.array([l_1, l_2, l_3, l_4, l_5, l_6, r_1, r_2, r_3, r_4, r_5]))
    q=np.array([0,0,0,0,0], dtype=float)

    error=np.linalg.norm(target-F_q)
    rospy.loginfo(error)

    while(error>1):
        Jt_subbed=Jt_subbed.subs([(cos, np.cos), (sin, np.sin), (l1, l_1), (l2,l_2), (l3, l_3), (l4,l_4), (l5,l_5), (l6,l_6), (r1,q[0]), (r2,q[1]), (r3,q[2]), (r4,q[3]), (r5,q[4])])
        Jt_np=np.array(Jt_subbed).astype(np.float64)
        F_q=forward(np.array([l_1, l_2, l_3, l_4, l_5, l_6, q[0], q[1], q[2], q[3], q[4]]))
        #print(Jt_np@(target-F_q))
        adjustment=np.reshape([0.001*Jt_np@(target-F_q)], (5,))
        q+=adjustment
        error=np.linalg.norm(target-F_q)
        rospy.loginfo(error)

    #print(position)
    #print(Jacobian)
    #print(Jacobian.shape)
    q_final=np.radians(np.mod(np.degrees(q),360))
    rospy.loginfo(np.radians(np.mod(np.degrees(q),360)))
    rospy.loginfo(np.mod(np.degrees(q),360))

    rospy.loginfo(forward(np.array([l_1, l_2, l_3, l_4, l_5, l_6, q_final[0], q_final[1], q_final[2], q_final[3], q_final[4]])))
    return np.degrees(q_final)

def callback(target):
    target_x=target.position.x
    target_y=target.position.y
    target_z=target.position.z
    q_final=inverse(target_x, target_y, target_z)
    q_final_string=str(q_final[0])+'q'+str(q_final[1])+'q'+str(q_final[2])+'q'+str(q_final[3])+'q'+str(q_final[4])+'q'
    rospy.loginfo(q_final_string)
    ser.write(q_final_string.encode('utf-8'))

rospy.init_node('actuation')
reverse_sub=rospy.Subscriber('pose', Pose, callback=callback)

while True:
    rospy.spin()