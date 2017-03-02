#!/bin/bash
echo "Installing OpenCV3 from source with GPU support.  This will take a while."
#http://elinux.org/Jetson/Installing_OpenCV
#http://docs.opencv.org/3.0-beta/doc/tutorials/introduction/linux_install/linux_install.html
sudo add-apt-repository universe
sudo apt-get update

# Some general development libraries
sudo apt-get -y install build-essential make cmake cmake-curses-gui g++ git pkg-config
# libav video input/output development libraries
sudo apt-get -y install libavformat-dev libavutil-dev libswscale-dev libavcodec-dev 
# Video4Linux camera development libraries
sudo apt-get -y install libv4l-dev
# Eigen3 math development libraries
sudo apt-get -y install libeigen3-dev
# OpenGL development libraries (to allow creating graphical windows)
sudo apt-get -y install libglew1.6-dev
# GTK development libraries (to allow creating graphical windows)
sudo apt-get -y install libgtk2.0-dev
# optional
sudo apt-get -y install python-dev python-numpy libtbb2 libtbb-dev libjpeg-dev libpng-dev libtiff-dev libjasper-dev libdc1394-22-dev

git clone https://github.com/Itseez/opencv.git
cd opencv

#git clone https://github.com/Itseez/opencv_contrib.git
#cd opencv_contrib

#git checkout tags/3.0.0

mkdir build
cd build
# I got this warning, but did not have time to test the install. jlb 3-2-17

#CMake Warning:
#  Manually-specified variables were not used by the project:
#
#    CUDA_ARCH_BIN
#    CUDA_ARCH_PTX
#

cmake -DWITH_CUDA=ON -DCUDA_ARCH_BIN="3.2" -DCUDA_ARCH_PTX="" -DBUILD_TESTS=OFF -DBUILD_PERF_TESTS=OFF -DCMAKE_INSTALL_PREFIX=/usr ..

sudo make -j4 install

echo "# Use OpenCV and other custom-built libraries." >> ~/.bashrc
echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib/" >> ~/.bashrc
source ~/.bashrc

#echo "Do you want to test the OpenCV3 build?"
#select yn in "Yes" "No"; do
#    case $yn in
#        Yes ) ccmake ..;; 
#        No ) cmake -DWITH_CUDA=ON -DCUDA_ARCH_BIN="3.2" -DCUDA_ARCH_PTX="" -DBUILD_TESTS=OFF -DBUILD_PERF_TESTS=OFF ..;;
#    esac

        
# Install ROS if it is not already installed.
if [ ! -d /opt/ros/kinetic/ ]; then
    # This part very closely follows the instructions from:
    #   http://wiki.ros.org/kinetic/Installation/Ubuntu
    ROS_DISTRO='kinetic'

    # The "codename" for this Ubuntu release (lucid, trusty, etc.).
    UBUNTU_CODENAME=`lsb_release -sc`
    # The entry for the ROS sources list we will create.
    ROS_SRC_ENTRY="deb http://packages.ros.org/ros/ubuntu $UBUNTU_CODENAME main"
    # The filepath for the ROS sources list we will create.
    ROS_SRC_LIST="/etc/apt/sources.list.d/ros-latest.list"

    # Echo the entry into a new sources list file.
    # This will also overwrite any already existing file.
    sudo sh -c "echo $ROS_SRC_ENTRY > $ROS_SRC_LIST"

    # Get the ROS key and add it to apt.
    wget 'https://raw.githubusercontent.com/ros/rosdistro/master/ros.key' -O - | sudo apt-key add -

    # Finally, update our package lists and then install ROS.
    sudo apt-get update
    sudo apt-get install ros-kinetic-desktop
fi

# Installing additional packages.
sudo apt-get install doxygen ros-kinetic-uwsim ros-kinetic-underwater-vehicle-dynamics  ros-kinetic-robot-localization libopencv-dev #if we change ros-kinetic-desktop to ros-kinetic-desktop-full we can remove the uwsim bit
# Installing dependencies for the embedded tool-chain
sudo apt-get install curl flex bison texinfo libelf-dev autoconf build-essential libncurses5-dev libusb-1.0-0-dev 

# Setup environment variables for ROS.
echo "source /opt/ros/kinetic/setup.bash" >> ~/.bashrc
source ~/.bashrc

# Initialize rosdep if it is not already initialized.
if [ ! -d /etc/ros/rosdep/ ]; then
    sudo rosdep init
    rosdep update
fi

# Finally, run rosdep to install all the dependencies for our packages.
sudo rosdep install -y -r --reinstall --from-paths $(dirname $0)/../src --rosdistro kinetic

# Install QtCreator and its ROS plugin.
# Due to a quirk of the plugin, qtcreator MUST be installed twice.
echo "Do you want to install optional IDE QtCreator and associated ROS plugin?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) sudo apt install qtcreator; 
            # This command broke the install on ubuntu 16.04.2
            #sudo add-apt-repository ppa:beineri/opt-qt57-xenial;
            #https://github.com/ros-industrial/ros_qtc_plugin/wiki/1.-How-to-Install-(Users)
            #sudo add-apt-repository --remove ppa:beineri/opt-qt57-xenial
            sudo add-apt-repository ppa:levi-armstrong/qt-libraries-xenial; 
            sudo add-apt-repository ppa:levi-armstrong/ppa;
            sudo apt-get update && sudo apt-get install qt57creator-plugin-ros;
            sudo apt install qtcreator; break;;
        No ) exit;;
    esac
done
