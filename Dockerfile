FROM ros:noetic-ros-core-focal

#setup ros prerequisites
RUN apt update && apt install --no-install-recommends -y \
    python3

RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'\
    sudo apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654


#setup ros
RUN apt update && apt install -y --no-install-recommends \
    ros-noetic-ros-base=1.50-1* \
    && rm 0rf /var/lib/apt/lists/*

#workspace build prerequisites
RUN apt update && apt install --no-install-recommends -y \
    build-essential \
    python3-rosdep \
    python3-tosinstall \
    python3-rosinstall-generator \
    python3-wstools \
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
USER $USER

#set custom home to the user
RUN HOME=~/ rosdep update

#Create a catkin workspace
RUN mkdir -p ~/catkin_ws/src
RUN cp -r $PWD/Std_Robo ~/
RUN /bin/bash -c './opt/ros/noetic/setup.bash; catkin_init_workspace ~/catkin_ws/src'
RUN /bin/bash -c './opt/ros/noetic/setup.bash; cd ~/catkin_ws; catkin_make'
ADD bashrc /.bashrc
ADD bashrc ~/.bashrc

#Move files into the workspace and build
RUN mv ~/Std_Robo ~/catkin_ws/src/sr_pkg/Std_Robo \
    cd ~/catkin_ws \
    catkin_make \
    source devel/setup.bash

#Build the rosnode in the workspace
CMD ["/bin/bash"]
ENTRYPOINT ["/usr/local/bin/startcontainer"]
