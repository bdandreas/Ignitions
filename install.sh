#!/bin/bash -e

sudo apt-get clean
sudo mv /var/lib/apt/lists /tmp
sudo mkdir -p /var/lib/apt/lists/partial
sudo apt-get clean

# First a complete new database
apt-get update  && apt-get install -y ruby ruby-dev

# Install GNU dependencies
echo "=========== Installing dependencies ============"
apt-get install -y build-essential

# Install preinstalled php5 version
# Will be remove once php7 is installed
apt-get install -y git wget cmake libreadline-dev libzmq-dev mcrypt libmcrypt-dev joe curl libfreetype6-dev git-core autoconf bison libxml2-dev libbz2-dev libcurl4-openssl-dev libltdl-dev libpng-dev libpspell-dev libreadline-dev \
libpng12-dev

#
# Add software repositories
apt-get install -y software-properties-common python-software-properties

# Install dependencies
echo "=========== Installing dependencies ============"
apt-get build-dep -y php5-cli
apt-get install -y php5-dev php5-sqlite

# Install Thirth Party Libraries here.
# Add repository
add-apt-repository ppa:ubuntu-mozilla-security/ppa

apt-get install -y firefox

# Install Java dependencies
apt-get install -y openjdk-7-jre

# PHPUnit installer
#apt-get install -y phpunit

# PHPUnit 5.x lastest version only work on php 7
#apt-get install -y phpunit
wget https://phar.phpunit.de/phpunit.phar
chmod +x phpunit.phar
mv phpunit.phar /usr/local/bin/phpunit

# Install libmemcached
echo "========== Installing libmemcached =========="
wget https://launchpad.net/libmemcached/1.0/1.0.18/+download/libmemcached-1.0.18.tar.gz
tar xzf libmemcached-1.0.18.tar.gz && cd libmemcached-1.0.18
./configure --enable-sasl
make && make install
cd .. && rm -fr libmemcached-1.0.18*

# Install phpenv
echo "============ Installing phpenv ============="
git clone git://github.com/CHH/phpenv.git $HOME/phpenv
$HOME/phpenv/bin/phpenv-install.sh
echo 'export PATH=$HOME/.phpenv/bin:$PATH' >> $HOME/.bashrc
echo 'eval "$(phpenv init -)"' >> $HOME/.bashrc
rm -rf $HOME/phpenv

# Install php-build
echo "============ Installing php-build =============="
git clone git://github.com/php-build/php-build.git $HOME/php-build
$HOME/php-build/install.sh
rm -rf $HOME/php-build

# Activate phpenv
echo "============ Activate phpenv ============="
export PATH=$HOME/.phpenv/bin:$PATH
eval "$(phpenv init -)"

#Download pickle 
git clone https://github.com/FriendsOfPHP/pickle.git /tmp/pickle

# Install librabbitmq
echo "============ Installing librabbitmq ============"
cd /tmp && wget https://github.com/alanxz/rabbitmq-c/releases/download/v0.7.1/rabbitmq-c-0.7.1.tar.gz
tar xzf rabbitmq-c-0.7.1.tar.gz
mkdir build && cd build
cmake /tmp/rabbitmq-c-0.7.1
cmake -DCMAKE_INSTALL_PREFIX=/usr/local /tmp/rabbitmq-c-0.7.1
cmake --build . --target install
cd /tmp/rabbitmq-c-0.7.1
autoreconf -i
./configure
make
make install

mkdir -p /var/www/git_repos/ /var/www/git_repos/master
cd /var/www/git_repos
ln -s master aplha
ln -s master production
cd /var/www/git_repos


#
# iNSTALLING php 7

#Build PHP 7.0.2
echo "============ Building PHP 7.0.2 =============="
php-build -i development 7.0.2 $HOME/.phpenv/versions/7.0.2

# Setting phpenv to 7.0.2
echo "============ Setting phpenv to 7.0.2 ============"
phpenv rehash
phpenv global 7.0.2

# Install Composer
echo "============ Installing Composer ============"
curl -s http://getcomposer.org/installer | php
chmod +x composer.phar
mv composer.phar $HOME/.phpenv/versions/7.0.2/bin/composer

#install pickle
cd /tmp/pickle
$HOME/.phpenv/versions/7.0.2/bin/composer install

# Install php extensions
echo "=========== Installing PHP extensions =============="
printf '\n' | bin/pickle install apcu

# Cleaning package lists
echo "================= Cleaning package lists ==================="
apt-get clean
apt-get autoclean
apt-get autoremove
