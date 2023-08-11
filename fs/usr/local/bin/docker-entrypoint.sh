#!/usr/bin/env bash

echo "Starting SSH server..."
sudo ssh-keygen -A
sudo /etc/init.d/ssh start
if [[ -n ${PASSWORD} ]]; then
  echo "Using provided password for user."
else
  PASSWORD=$(C_ALL=C tr -dc A-Za-z0-9 </dev/urandom | head -c 12)
  echo "Setting user php-ide's password to ${PASSWORD}... Remember, this changes every time container is started."
fi

sudo echo "ide-user:${PASSWORD}" | chpasswd

if [[ -n ${SSH-KEY} ]]; then
  echo "${SSH-KEY}" > /home/ide-user/.ssh/authorized_keys
  chown ide-user:ide-user /home/ide-user/.ssh/authorized_keys
  chmod 600 /home/ide-user/.ssh/authorized_keys
fi

# Run any custom startup scripts
[[ -f $PWD/start.sh ]] && bash $PWD/start.sh

# Run the command passed to the container
exec "$@"