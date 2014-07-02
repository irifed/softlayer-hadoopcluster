#!/bin/bash

# Install Oracle Java for the cases when Openjdk is not working
# (Usually this is not necessary. OpenJDK 7 works out of box in Ubuntu 14.04)

# http://stackoverflow.com/questions/13018626/add-apt-repository-not-found
# cannot work unattended, because asks for license agreement acceptance
# apt-get install python-software-properties
# add-apt-repository -y ppa:webupd8team/java  
# apt-get update 
# apt-get install -y oracle-java7-installer  

# alternative java installation
# http://www.wikihow.com/Install-Oracle-Java-JRE-on-Ubuntu-Linux
apt-get install gsfonts gsfonts-x11 java-common libfontenc1 libxfont1 x11-common xfonts-encodings xfonts-utils
wget -O jre-7u60-linux-x64.tar.gz http://javadl.sun.com/webapps/download/AutoDL?BundleId=90216
tar xfvz jre-7u60-linux-x64
mv jre1.7.0_60 /usr/local
pushd /usr/local
ln -s jre1.7.0_60 java

cat > /etc/profile << EOF
export JAVA_HOME=/usr/local/java
export PATH=$HOME/bin:$JAVA_HOME/bin:$PATH
EOF
update-alternatives --install "/usr/bin/java" "java" "/usr/local/java/bin/java" 1
update-alternatives --install "/usr/bin/javaws" "javaws" "/usr/local/java/bin/javaws" 1
update-alternatives --set java /usr/local/java/bin/java

