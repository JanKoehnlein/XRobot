XRobot
======

SDK Installation:

You need
- JDK 7
- Eclipse Luna 
- Xtext SDK 2.7.x + Xtext Antlr
- leJOS EV3 0.8.1beta (http://www.lejos.org)
- OpenCV 2.4.9 binary distro for your platform (http://opencv.org/)

Configure Base Eclipse (only if you want to rebuild BrickConnector.jar)
- Import org.lejos.ev3.ldt (contains a patch adding tend libs to the class path of the compiled jars).
- Start runtime Eclipse

Configure (Runtime) Eclipse
- Import projects
- Set EV3_HOME on Preferences > leJOS EV3
- Add a User library 'OpenCV' under Preferences > Java > Build Path > User Libraries 
  - Add External JAR > <OpenCV Home>/build/bin/opencv_249.jar
  - Set native library location  <OpenCV Home>/build/lib

EV3 setup
- format SD card in FAT32
- unzip EV3/sdbootstrap.zip to SD card
- insert SD card into EV3 brick and start it. Autosetup takes about 10mins.
- change brick name ('Xtext' or 'Xtend')
- setup WiFi
- deploy XRobot on EV3 /home/lejos/programs (scp <file> root@<brick IP>:/home/lejos/programs)
 - current BrickConnector.jar (see below)
 - com.google.guava_15.0.0.v201403281430.jar - org.eclipse.xtext.xbase.lib_2.7.0.v201408180851.jar

Build and deploy XRobot BrickConnector (requires patched leJOS LDT, see above)
- Right-click on /org.xtext.xrobot/xtend-gen/org/xtext/xrobot/client/BrickConnector.java and select
  Run As > LeJOS EV3 Program

Run the Application
- Start a runtime Eclipse
- Create a plug-in project with dependencies to org.eclipse.xtext.xbase.lib and org.xtext.xrobot
- Create an *.xrobot file in the src folder
- In the editor right-click and select Run Script on Robot 'XXX'


