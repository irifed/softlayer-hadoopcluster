softlayer-hadoopcluster
=======================

Scripts for installing Hadoop. Tested on Ubuntu 14.04 virtual server from SoftLayer.

First, it is necessary to install Java. In most cases 
```
sudo apt-install openjdk-7-jdk
```
will be sufficient. In case if OpenJDK does not work on a certain Linux distribution for some reason, other option is to
install Oracle Java 7. There are couple of further options: either download Java from Oracle website or add 3rd party
repository. Detailed steps are outlined in `install_java.sh`

Script `install_hadoop.sh` installs Hadoop and makes basic server setup (create hadoop user, enable passwordless SSH,
etc).
It is important to note that Hadoop distribution from Apache website is built in 32-bit mode.
In order to use Hadoop on a 64-bit machine it is necessary to build 64-bit version from scratch, otherwise Hadoop does
not start correctly.

I have built 64-bit Hadoop 2.4.1 from sources: [download here](http://hadoop-2.4.1-64bit.s3.amazonaws.com/hadoop-2.4.1-x86_64.tar.gz)
`install_hadoop.sh` script will use this pre-built distribution by default.
