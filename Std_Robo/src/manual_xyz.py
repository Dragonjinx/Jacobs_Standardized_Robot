#!/usr/bin/env python3
import rospy
from geometry_msgs.msg import Pose
import sys
from PyQt5 import QtWidgets, QtGui, QtCore
from PyQt5.QtWidgets import QApplication, QMainWindow, QMessageBox, QInputDialog

rospy.init_node("manual_gui")
xyz_pub=rospy.Publisher('pose', Pose, queue_size=1)

class window(QMainWindow):
    def __init__(self):
        super(window, self).__init__()
        self.setGeometry(700, 200, 300, 200)
        self.setStyleSheet("background : grey")

        self.b1 = QtWidgets.QPushButton(self)
        self.b1.setGeometry(50, 50, 100, 100)
        self.b1.setText("Set xyz")
        self.b1.clicked.connect(self.b1_clicked)

        self.label=QtWidgets.QLabel(self)
        self.label.setGeometry(200, 50, 200, 100)
        self.label.setFont(QtGui.QFont('Arial', 13))
        self.label.setText("x:\ny:\nz:\n")
    
    def b1_clicked(self):
        self.xyz=QInputDialog(self)
        self.x, xpressed=self.xyz.getDouble(self,"Set x target", "", 0, -35, 35, 1)
        self.y, ypressed=self.xyz.getDouble(self,"Set y target", "", 0, -35, 35, 1)
        self.z, zpressed=self.xyz.getDouble(self,"Set z target", "", 0, 0, 47, 1)
        
        target=Pose()
        target.position.x=self.x
        target.position.y=self.y
        target.position.z=self.z
        xyz_pub.publish(target)

app=QApplication(sys.argv)
win=window()
win.show()

def callback(pose):
    x=pose.position.x
    y=pose.position.y
    z=pose.position.z
    win.label.setText("x:"+str(x)+"\ny:"+str(y)+"\nz:"+str(z)+"\n")

xyz_sub=rospy.Subscriber('pose', Pose, callback=callback)
sys.exit(app.exec_())