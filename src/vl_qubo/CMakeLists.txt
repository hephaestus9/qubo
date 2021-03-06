cmake_minimum_required(VERSION 2.8.3)
project(vl_qubo)

find_package(catkin
    REQUIRED COMPONENTS
    roscpp
    ram_msgs
)


catkin_package(
    LIBRARIES ${PROJECT_NAME}
    INCLUDE_DIRS
    CATKIN_DEPENDS roscpp
)


##############################
# File List ##################
##############################

include_directories(
  ${catkin_INCLUDE_DIRS}
  drivers/ahrs/include
  drivers/dvl/include

  ahrs/include
  dvl/include
  include

)

set(CMAKE_CXX_FLAGS "-std=c++11 ${CMAKE_CXX_FLAGS}")

SET(CMAKE_C++_CREATE_SHARED_LIBRARY 1)

#SG: currently unused, eventually we'll add a wrapper with a main and build them together.
set(AHRS_SRC_FILES
    ahrs/src/main.cpp
    ahrs/src/ahrs_qubo.cpp
    drivers/ahrs/src/AHRS.cpp
)

#SG: ditto above
set(DVL_SRC_FILES
         dvl/src/main.cpp
         dvl/src/dvl_qubo.cpp
         drivers/dvl/src/DVL.cpp
)

set(AHRS_CONFIG_SRC_FILES
        drivers/ahrs/src/config.cpp
        drivers/ahrs/src/util.cpp

        drivers/ahrs/src/AHRS.cpp # SG: maybe putting this here is not the best way to do this, but it will work for now
)

set(AHRS_BAUDRATE_SRC_FILES
        drivers/ahrs/src/baudrate.cpp
        drivers/ahrs/src/util.cpp

        drivers/ahrs/src/AHRS.cpp #SG: ditto above
)


##############################
# Add Executables ############
##############################


add_executable(ahrs_config ${AHRS_CONFIG_SRC_FILES})
#target_link_libraries(ahrs_config ${PROJECT_NAME})

add_executable(ahrs_baudrate ${AHRS_BAUDRATE_SRC_FILES})
#target_link_libraries(ahrs_baudrate ${PROJECT_NAME})

add_executable(qubo_ahrs_node ${AHRS_SRC_FILES})
target_link_libraries(qubo_ahrs_node ${catkin_LIBRARIES})

add_executable(qubo_dvl_node ${DVL_SRC_FILES})
target_link_libraries(qubo_dvl_node ${catkin_LIBRARIES})
add_dependencies(qubo_dvl_node ram_msgs_generate_messages_cpp)

##############################
# Installable Targets ########
##############################


#install(TARGETS ${PROJECT_NAME}
 #       ARCHIVE DESTINATION ${CATKIN_PACKAGE_LIB_DESTINATION}
 #       LIBRARY DESTINATION ${CATKIN_PACKAGE_LIB_DESTINATION}
 #      RUNTIME DESTINATION ${CATKIN_GLOBAL_BIN_DESTINATION}
#)

install(DIRECTORY include/${PROJECT_NAME}/
        DESTINATION ${CATKIN_PACKAGE_INCLUDE_DESTINATION})
