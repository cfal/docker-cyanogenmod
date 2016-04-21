# Build environment for CyanogenMod

FROM ubuntu:14.04
MAINTAINER Michael Stucki <mundaun@gmx.ch>

ENV DEBIAN_FRONTEND noninteractive

RUN sed -i 's/main$/main universe/' /etc/apt/sources.list
RUN apt-get -qq update
RUN apt-get -qqy upgrade

# Install build dependencies (source: https://wiki.cyanogenmod.org/w/Build_for_angler)
RUN apt-get install -y bison build-essential curl flex git gnupg gperf libesd0-dev liblz4-tool libncurses5-dev libsdl1.2-dev libwxgtk2.8-dev libxml2 libxml2-utils lzop maven openjdk-7-jdk openjdk-7-jre pngcrush schedtool squashfs-tools xsltproc zip zlib1g-dev
RUN apt-get install -y g++-multilib gcc-multilib lib32ncurses5-dev lib32readline-gplv2-dev lib32z1-dev

# Install additional packages which are useful for building Android
RUN apt-get install -y ccache rsync tig
RUN apt-get install -y android-tools-adb android-tools-fastboot
RUN apt-get install -y bc bsdmainutils file tmux
RUN apt-get install -y bash-completion wget nano zsh

RUN useradd -d /cm -s /bin/zsh cm && rsync -a /etc/skel/ /cm/

# Add zsh
RUN git clone git://github.com/robbyrussell/oh-my-zsh.git /cm/.oh-my-zsh
RUN cp -vf /cm/.oh-my-zsh/templates/zshrc.zsh-template /cm/.zshrc

RUN mkdir /cm/bin
RUN curl http://commondatastorage.googleapis.com/git-repo-downloads/repo > /cm/bin/repo
RUN chmod a+x /cm/bin/repo

# Add sudo permission
RUN echo "cm ALL=NOPASSWD: ALL" > /etc/sudoers.d/cm

ADD .tmux.conf /cm/.tmux.conf
ADD startup.sh /cm/startup.sh
RUN chmod a+x /cm/startup.sh

# Fix ownership
RUN chown -v cm:cm /cm /cm/.tmux.conf /cm/.oh-my-zsh /cm/.zshrc /cm/startup.sh /cm/.profile

# Set global variables
ADD android-env-vars.sh /etc/android-env-vars.sh
RUN echo "source /etc/android-env-vars.sh" >> /etc/bash.bashrc

VOLUME /cm/android
VOLUME /srv/ccache

CMD /cm/startup.sh

USER cm
WORKDIR /cm/android
