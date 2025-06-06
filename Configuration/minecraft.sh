#!bin/bash
sudo apt-get update && sudo apt-get upgrade -y
sudo apt install openjdk-21-jdk -y
sudo mkdir /opt/minecraft
sudo mkdir /opt/minecraft/server
cd /opt/minecraft/server
wget https://piston-data.mojang.com/v1/objects/e6ec2f64e6080b9b5d9b471b291c33cc7f509733/server.jar
java -Xmx1024M -Xms1024M -jar server.jar nogui
sleep 40
sed -i 's/false/true/p' eula.txt
touch start
printf '#!/bin/bash\njava -Xmx1300M -Xms1300M -jar server.jar nogui\n' >> start
chmod +x start
sleep 1
touch stop
printf '#!/bin/bash\nkill -9 $(ps -ef | pgrep -f "java")' >> stop
chmod +x stop
sleep 1

# Create SystemD Script to run Minecraft server jar on reboot
cd /etc/systemd/system/
touch minecraft.service
printf '[Unit]\nDescription=Minecraft Server on start up\nWants=network-online.target\n[Service]\nWorkingDirectory=/opt/minecraft/server\nExecStart=/opt/minecraft/server/start\nExecStop=/opt/minecraft/server/stop\nStandardInput=null\n[Install]\nWantedBy=multi-user.target' >> minecraft.service
sudo systemctl daemon-reload
sudo systemctl enable minecraft.service
sudo systemctl start minecraft.service