FROM ros:noetic-ros-core-focal

#setup ros prerequisites
RUN apt update && apt install --no-install-recommends -y \
    python3 \
    git

RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'\
    sudo apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654


#setup ros
RUN apt update && apt install -y --no-install-recommends \
    ros-noetic-ros-base \
    && rm -rf /var/lib/apt/lists/*

#workspace build prerequisites
RUN apt update && apt install --no-install-recommends -y \
    python3-rosdep \
    python3-rosinstall \
    python3-rosinstall-generator \
    python3-wstool \
    build-essential \
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
RUN /bin/bash -c 'git clone https://github.com/Dragonjinx/Jacobs_Standardized_Robot.git ~/Jacobs_Standardized_Robot' \
RUN /bin/bash -c 'cd ~/Jacobs_Standardized_Robot; git checkout Docker' \
RUN cp -r ~/Jacobs_Standardized_Robot/Std_Robo ~/catkin_ws/src/sr_pkg/
RUN /bin/bash -c '. /opt/ros/noetic/setup.bash; cd ~/catkin_ws; catkin_make'
RUN /bin/bash -c "source ~/.bashrc"

#Build the rosnode in the workspace
CMD ["/bin/bash"]