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
#ADD startcontainer /usr/local/bin/startcontainer
#RUN chmod 755 /usr/local/bin/startcontainer

#RUN adduser --gecos "ROS User" --disabled-password ros
#RUN usermod -a -G dialout ros

# I don't understand after this
#RUN mkdir /var/run/sshd

#ADD 99_aptget /etc/sudoers.d/99_aptget
#RUN chmod 0440 /etc/sudoers.d/99_aptget && chown root:root /etc/sudoers.d/99_aptget

#RUN echo "    ForwardX11Trusted yes\n" >> /etc/ssh/ssh_config

#select created user
#USER $USER

#set custom home to the user
RUN HOME=~/ rosdep update

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
RUN git clone https://github.com/Dragonjinx/Jacobs_Standardized_Robot.git \
    && /bin/bash -c 'git checkout Docker'

RUN cp -r ~/Jacobs_Standardized_Robot/Std_Robo ~/catkin_ws/src/sr_pkg/
RUN cd ~/catkin_ws
RUN /bin/bash -c '. /opt/ros/noetic/setup.bash; cd ~/catkin_ws; catkin_make'
RUN /bin/bash -c "source ~/.bashrc"

#Build the rosnode in the workspace
CMD ["/bin/bash"]
ENTRYPOINT ["/usr/local/bin/startcontainer"]
