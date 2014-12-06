XRobots
=======

SDK Installation:

You need
- JDK 7
- Eclipse Luna 
- Xtext SDK 2.7.x + Xtext Antlr
- leJOS EV3 0.8.1beta (http://www.lejos.org)

Configure Eclipse
- Import projects
- Set EV3_HOME on Preferences > leJOS EV3

EV3 Setup (for each EV3 brick)
- format SD card in FAT32
- unzip EV3/sdbootstrap.zip to SD card
- insert SD card into EV3 brick and start it. Autosetup takes about 10mins.
- change brick name ('Blue' or 'Red')
- setup WiFi
- Run External Tool Configuration 'Deploy on Bricks' to deploy BrickConnector.jar
- Deploy additional libraries: scp <file> root@<brick IP>:/home/lejos/programs
 - org.eclipse.xtext.xbase.lib_2.7.x
 - com.google.guava_15.0.x
 - org.apache.log4j_1.2.x

Install and Run Xtrack
- Clone and compile https://github.com/franchi82/xtrack
- Connect an HD webcam and run the tracking application

Run the Game
- Start the BrickConnector program on the EV3s
- Run the 'Start Game Server' configuration
