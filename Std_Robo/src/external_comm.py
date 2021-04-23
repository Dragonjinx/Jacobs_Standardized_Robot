import rospy
from std.msgs.msg import String
import sys, time

def send(message):
    #do something with the message before sending to external node
    external_pub.publish(message)

def recieve(message):
    #decode the message recieved
    #Do something with if idk run a bash script, you creative
    fi = open("~/Logs.txt", 'w')
    fi.write(str(message).encode('utf-8'))
    fi.close()

rospy.init_node("external_comms")
#Open a port to send and recieve messages

#This subscriber gets messages from serial_comm.py
get_msg=rospy.Subscriber('serial_commands', String, callback=send)
#This published to any node listening to the ext_output topic
external_pub=rospy.Publisher('ext_output', String, queue_size=1)
#Thus subscriber gets messages from any external node publishing to ext_input topic
external_sub=rospy.Sobscriber('ext_input', String, callback=recieve)

#Spin to keep script running
rospy.spin()