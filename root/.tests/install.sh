#!/bin/bash

echo 'L                                       TTTTTTT                         '
echo 'L           i    v    v  eeeeee            T     eeeeee   ssss    ttttt '
echo 'L           i    v    v  e                 T     e       s          t   '
echo 'L           i    v    v  eeeee             T     eeeee    ssss      t   '
echo 'L           i    v    v  e                 T     e            s     t   '
echo 'L           i     v  v   e                 T     e       s    s     t   '
echo 'LLLLLLL     i      vv    eeeeee            T     eeeeee   ssss      t   '
echo -e '\n\nAutomatic installer\n'

if [ "$UID" -ne "0"  ] 
  then
  echo 'You must be root to instsall Live Test !'
  exit
fi

## BEGIN PROGRAM

read -p "Type the absolut path of the project's root folder: " PROJECT_ROOT

if ! [[ -z "$PROJECT_ROOT" ]]
then
  cd $PROJECT_ROOT
else
  echo "Live Test will be installed to the current directory."
fi

if [ -d "${PWD}/.tests/lib" ]; then
  echo 'You already have Live Test installed. Be happy: updating requirements...'  
else
  echo -e 'Downloading Live Tests...\n'
  wget http://www.toetec.com.br/live_test.tar.gz  
  echo -e 'Unpacking the file...\n'
  tar -xzvf live_test.tar.gz  
  echo -e 'Installing requirements...\n'
fi

cd .tests

apt-get update &> /dev/null

hash ruby1.9.3 &> /dev/null || {
	echo '+ Installing Ruby1.9.3'
	apt-get install -y ruby1.9.3 > /dev/null
}

hash xvfb &> /dev/null || {
	echo '+ Installing xvfb'
	apt-get install -y xvfb > /dev/null
}

hash firefox &> /dev/null || {
	echo '+ Installing Firefox'
	apt-get install -y firefox > /dev/null
}

hash make &> /dev/null || {
	echo '+ Installing make'
	apt-get install -y make > /dev/null
}

hash bundler &> /dev/null || {
	echo '+ Installing bundler'
	gem install bundler  > /dev/null
}

hash bundle &> /dev/null || {
	echo '+ Installing required gems...'
	bundle install  > /dev/null
}

hash rllangs &> /dev/null || {
	echo '+ Setting i18n support...'
	RL_LANGS="en,pt"  > /dev/null
}

hash filefind &> /dev/null || {
        echo '+ Installing/updating File::Find::Rule...'
        cpan -fi File::Find::Rule >/dev/null
}

#@todo: run test and create results.html and screenshot folder
#add option for creating symbolic link from drupal files folder
#to the created results.html.

#rm ../live_test.tar.gz

echo "Done. Run it with: cucumber BASE_URL='<url>'. README.md for full set of options."
