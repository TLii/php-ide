# This image is used to run PHP IDEs (e.g. PhpStorm) in a containerized environment.
# Included: PHP, Composer, Helm, Docker CLI, SSH server, xdebug, phpunit

FROM mcr.microsoft.com/devcontainers/base:debian-12
EXPOSE 22

## FUNDAMENTALS ##
# Install base system
RUN apt-get update && apt-get install --no-install-recommends -y \
      openssh-server \
      vim \
      ca-certificates \
      curl \
      apt-transport-https \
      git \
      gnupg \
      unzip \
      lsb-release \
      sudo \
      coreutils

COPY fs /

RUN chmod 777 /usr/local/bin/docker-entrypoint.sh

# Install PHP and xdebug
RUN apt-get install --no-install-recommends -y \
    php-cli \
    php-curl \
    php-mbstring \
    php-xml \
    php-zip \
    php-pear \
    php-bcmath \
    phpunit


## SETUP ADDITIONAL TOOLS ##
# Setup Helm
RUN curl https://baltocdn.com/helm/signing.asc | gpg --dearmor |  tee /usr/share/keyrings/helm.gpg > /dev/null; \
    echo "deb [signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list && \
    apt-get update && apt-get install -y helm

# Setup Docker
# RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
#     echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian bookworm stable" | tee /etc/apt/sources.list.d/docker.list && \
#     apt-get update && apt-get install -y docker-ce

# Install hadolint
RUN curl https://github.com/hadolint/hadolint/releases/download/v2.12.0/hadolint-Linux-x86_64 -o /usr/local/bin/hadolint && \
    chmod +x /usr/local/bin/hadolint

# Install composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer

RUN usermod -aG sudo,vscode vscode && \
    mkdir -p /home/vscode/.ssh && \
    chown -R vscode:vscode /home/vscode/.ssh && \
    chmod 700 /home/vscode/.ssh && \
    echo "vscode ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

VOLUME /home/vscode

WORKDIR /home/vscode
USER 1000
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["sudo", "/usr/sbin/sshd","-D"]