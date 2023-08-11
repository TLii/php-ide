#!/usr/bin/env bash

echo "Starting SSH server..."
sudo ssh-keygen -A
sudo /etc/init.d/ssh start

# Set user password and SSH key, if provided
echo "Setting user php-ide's password to ${PASSWORD}..."
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