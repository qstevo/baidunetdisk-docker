FROM ubuntu:20.04

ENV BAIDUNETDISK_PACKAGE https://issuepcdn.baidupcs.com/issue/netdisk/LinuxGuanjia/4.12.5/baidunetdisk_4.12.5_amd64.deb
ENV NOVNC_PACKAGE https://github.com/novnc/noVNC/archive/refs/tags/v1.3.0.tar.gz

ENV VNC_SERVER_PASSWD password

ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8
# ENV LANGUAGE zh_CN:zh

# Variables needed for non interactive tzdata installation.
ENV TZ=America/Los_Angeles
ENV DEBIAN_FRONTEND="noninteractive"

RUN apt-get -y update && apt-get -qqy install apt-transport-https apt-utils && \
    apt-get -qqy install \
    supervisor \
    wget \
    x11vnc \
    xvfb \
    websockify \
    i3status \
    i3-wm \
    desktop-file-utils \
    libappindicator3-1 \
    libasound2 \
    libnss3 \
    libgtk-3-0 \
    libfontconfig \
    libfreetype6 \
    libgbm-dev \
    libnotify4 \
    libsecret-1-0 \
    xfonts-cyrillic \
    xfonts-scalable \
    fonts-liberation \
    fonts-ipafont-gothic \
    fonts-wqy-zenhei \
    xdg-utils && \
  rm -rf /var/lib/apt/lists/* && \
  apt-get -qyy clean

RUN mkdir /root/.vnc && \
  touch /root/.vnc/passwd

RUN wget ${BAIDUNETDISK_PACKAGE} -O baidunetdisk.deb && \
  dpkg -i baidunetdisk.deb && \
  rm baidunetdisk.deb -f

# Download and extract noVNC, then remove the version number in directory name.
RUN wget ${NOVNC_PACKAGE} -O novnc.tar.gz && \
  mkdir -p /root/novnc && \
  tar -xzf novnc.tar.gz -C /root/novnc && \
  rm novnc.tar.gz websockify.tar.gz -f && \
  mv /root/novnc/noVNC-* /root/novnc/noVNC && \
  echo -e \
  "<!DOCTYPE html>\n" \
  "<html>\n" \
  "    <head>\n" \
  "        <title>noVNC</title>\n" \
  "        <meta charset=\"utf-8\"/>\n" \
  "        <meta http-equiv=\"refresh\" content=\"1; URL=vnc_lite.html\" />\n" \
  "    </head>\n" \
  "    <body>\n" \
  "        <p><a href=\"vnc_lite.html\">noVNC Lite Client</a></p>\n" \
  "        <p><a href=\"vnc.html\">noVNC Full Client</a></p>\n" \
  "    </body>\n" \
  "</html>" \
  > /root/novnc/noVNC/index.html
  # openssl req -new -x509 -days 3650 -nodes -out /root/self.pem -keyout /root/self.pem -subj="/CN=self-novnc"

# Remove cap_net_admin capabilities to avoid failing with 'operation not permitted'.
RUN setcap -r `which i3status`

COPY supervisord.conf /root/supervisord.conf
COPY i3_config /root/.config/i3/config

EXPOSE 5900
EXPOSE 6080

CMD echo "VNC (vnc://localhost:5900) password is $VNC_SERVER_PASSWD" && \
  /usr/bin/x11vnc -storepasswd $VNC_SERVER_PASSWD ~/.vnc/passwd && \
  /usr/bin/supervisord -c /root/supervisord.conf && \
  /usr/bin/tail -f /dev/null
