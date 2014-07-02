#! /bin/bash -x

# Install Hadoop
# Can be run as SL postinstall script to prepare image for Hadoop cluster 

HADOOP_USER=hadoop
HADOOP_GROUP=hadoop
HADOOP_VERSION=2.4.1

# use `true` for building, otherwise pre-built distro will be downloaded from my S3
BUILD_NATIVE_LIBS=false

# Add dedicated user for Hadoop
addgroup $HADOOP_GROUP
adduser --ingroup $HADOOP_GROUP --disabled-password --gecos "" $HADOOP_USER

# Enable passwordless SSH for Hadoop user
mkdir /home/$HADOOP_USER/.ssh
chmod 0700 /home/$HADOOP_USER/.ssh
ssh-keygen -t rsa -b 2048 -f /home/$HADOOP_USER/.ssh/id_rsa -q -N ""
cat /home/$HADOOP_USER/.ssh/id_rsa.pub >> /home/$HADOOP_USER/.ssh/authorized_keys
chmod 0600 /home/$HADOOP_USER/.ssh/authorized_keys
chown -R $HADOOP_USER:$HADOOP_GROUP /home/$HADOOP_USER/.ssh

# Add Hadoop user to sudoers
cat >> /etc/sudoers << EOF
$HADOOP_USER ALL=(ALL) NOPASSWD:ALL
EOF

apt-get update
apt-get upgrade -y

# [optional] make the box a bit friendlier
apt-get install -y vim tmux htop git
git clone https://github.com/irifed/dotfiles-pub.git
ln -s dotfiles-pub/.vimrc $HOME/.vimrc
ln -s dotfiles-pub/.tmux.conf $HOME/.tmux.conf

# Install Hadoop
pushd /tmp

## For 32-bit server only
#wget http://www.carfab.com/apachesoftware/hadoop/common/current/hadoop-${HADOOP_VERSION}.tar.gz
#tar xfz hadoop-${HADOOP_VERSION}.tar.gz
#mv hadoop-${HADOOP_VERSION} /usr/local
#popd

# On 64-bit server we have to build Hadoop from source because Apache's binaries are 32-bit
# http://hadoop.apache.org/docs/r2.4.0/hadoop-project-dist/hadoop-common/NativeLibraries.html
# Note: Java JDK (not just JRE) is required
if [ $BUILD_NATIVE_LIBS ]; then
    apt-get install -y openjdk-7-jdk
    apt-get install -y maven zlib1g-dev cmake build-essential make protobuf-compiler pkg-config libssl-dev
    wget http://www.carfab.com/apachesoftware/hadoop/common/current/hadoop-${HADOOP_VERSION}-src.tar.gz
    tar xfvz hadoop-${HADOOP_VERSION}-src.tar.gz

#    # on Ubuntu 12.04 protobuf-compiler version is too old, so have to build from source
#    wget https://protobuf.googlecode.com/files/protobuf-2.5.0.tar.gz
#    tar xfvz protobuf-2.5.0.tar.gz
#    pushd protobuf-2.5
#    ./configure --disable-shared
#    make
#    make install

    # for successful building VM has to have 2GB RAM
    pushd hadoop-${HADOOP_VERSION}-src
    mvn package -Dmaven.javadoc.skip=true -Pdist,native -DskipTests -Dtar
    cp -r hadoop-dist/target/hadoop-${HADOOP_VERSION} /usr/local
    popd

else
    # Use pre-built 64-bit version 2.4.1
    HADOOP_VERSION=2.4.1
    wget http://hadoop-${HADOOP_VERSION}-64bit.s3.amazonaws.com/hadoop-${HADOOP_VERSION}-x86_64.tar.gz
    tar xfz hadoop-${HADOOP_VERSION}-x86_64.tar.gz
    mv hadoop-${HADOOP_VERSION} /usr/local 
fi

pushd /usr/local
chown -R ${HADOOP_USER}:${HADOOP_GROUP} hadoop-${HADOOP_VERSION}
ln -s hadoop-${HADOOP_VERSION} hadoop
popd

# return from /tmp
popd

# TODO configure Hadoop:
# 1) export JAVA_HOME=... in /usr/local/hadoop/etc/hadoop/hadoop.env
# 2) proper settings for clustered operation from here:
# (http://hadoop.apache.org/docs/r2.4.1/hadoop-project-dist/hadoop-common/SingleCluster.html)
# or (http://hadoop.apache.org/docs/r2.4.1/hadoop-project-dist/hadoop-common/ClusterSetup.html)

# TODO some programs (e.g. Crossbow) require that its components are accessible on all cluster nodes at the same path.
# To achieve this it is necessary to set up e.g. NFS
