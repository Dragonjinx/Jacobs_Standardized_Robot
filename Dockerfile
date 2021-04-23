FROM ros:noetic-ros-core-focal

#setup ros prerequisites
RUN apt update && apt install --no-install-recommends -y \
    python3 \
    git \
    nano

RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'\
    sudo apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654


#setup ros
RUN apt update && apt install -y --no-install-recommends \
    ros-noetic-ros-base \
    && rm -rf /var/lib/apt/lists/*

#workspace build prerequisites
RUN apt update && apt install --no-install-recommends -y \
    arduino-mk \
    python3-rosdep \
    python3-rosinstall \
    python3-rosinstall-generator \
    python3-wstool \
    build-essential \
    python3-sympy \
    python3-numpy \
    python3-pyqt5 \
    python3-pip \
    && python3 -m pip install pyserial \
    && rm -rf /var/lib/apt/lists/*

#initialize rosdep
RUN rosdep init && \
    rosdep update --rosdistro $ROS_DISTRO


#setup server-side services
RUN apt update && apt install -y --no-install-recommends \
    openssh-server \
    net-tools \
    nodejs \
    && apt autoclean \
    && apt autoremove \
    && rm -rf /var/lib/apt/lists/*


#Setup ros user (maybe optional)

# ADD startcontainer /root/startcontainer


RUN HOME=~/ rosdep update
RUN echo $(ls $HOME)

#option to add user

#Create a catkin workspace
RUN mkdir -p ~/catkin_ws/src
RUN chmod +x /opt/ros/noetic/setup.bash
RUN echo "source /opt/ros/noetic/setup.bash" >> ~/.bashrc
RUN /bin/bash -c "source ~/.bashrc"
#RUN cd ~/catkin_ws/src
#RUN /bin/bash -c '. /opt/ros/noetic/setup.bash; catkin_init_worksapce ~/catkin_ws/src' 
RUN cd ~/catkin_ws
RUN /bin/bash -c '. /opt/ros/noetic/setup.bash; cd ~/catkin_ws; catkin_make'
RUN echo "source ~/catkin_ws/devel/setup.bash" >> ~/.bashrc


#Move files into the workspace and build
RUN cd ~/
RUN /bin/bash -c 'git clone https://github.com/Dragonjinx/Jacobs_Standardized_Robot.git ~/Jacobs_Standardized_Robot'
#Move scripts
RUN /bin/bash -c 'cd ~/Jacobs_Standardized_Robot; git checkout Docker; mv Std_Robo/*.sh ~/'
#Move sketches
RUN /bin/bash -c 'cd ~/Jacobs_Standardized_Robot; git checkout Docker; mv Std_Robo/ ~/catkin_ws/src/sr_pkg'
RUN /bin/bash -c '. /opt/ros/noetic/setup.bash; cd ~/catkin_ws; catkin_make'
RUN /bin/bash -c "source ~/.bashrc"

# Server library downloaded from the arduino libraries:
# RUN /bin/bash -c 'cd ~/catkin_ws/src/sr_pkg/src/arm_arduino;\
#     git init;\
#     git config core.sparseCheckout true;\
#     git remote add -f origin https://github.com/arduino-libraries/Servo;\
#     echo "src"> .git/info/sparse-checkout;\
#     git pull origin master;\
#     mv ./src ./'

#Build the rosnode in the workspace

#Add automatic upload to arduino for entrypoint script

#Add automatic roslaunch to entrypoint script



CMD ["/bin/bash"]