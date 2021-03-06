#include "vision_node.h"

typedef actionlib::SimpleActionServer<ram_msgs::VisionExampleAction> Server;


int main(int argc, char** argv){
    if(argc != 6){
        ROS_ERROR("wrong number of arguments passed to vision node! you passed in %i, we wanted 6. node will exit now", argc);
        ROS_ERROR("we've standardized around using launch files to launch our nodes, yours should have the following line\n<node name=\"vision_node\" pkg=\"vision\" type=\"vision_node\" args=\"feed0 feed1 feedb\"/>\n where feed0 and feed1 and feedb are either physical camera paths .\n See the roslaunch folder in the drive if you want to find out what the other arguments roslaunch uses are"); 
        exit(0); 
    }
    // init the node handle
    ros::init(argc,argv, "vision_node");
    // node for testing  

    std::shared_ptr<ros::NodeHandle> n(new ros::NodeHandle);
    VisionNode node(n,argv[1],argv[2],argv[3]);

    
    Server server(*n, "vision_example", boost::bind(&VisionNode::test_execute, _1 , &server), false);
    server.start();
    
    ros::Rate r(10); // 10 hz
    while(ros::ok()){
        node.update();
        r.sleep(); //you update this time in the second argument to the VisionNode constructor
    }

    return 0;
}

