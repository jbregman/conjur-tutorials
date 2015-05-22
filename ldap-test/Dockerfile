from tomcat:8.0

RUN apt-get update
RUN apt-get -y install ldap-utils 

RUN wget -q https://s3.amazonaws.com/conjur-releases/omnibus/conjur_4.24.0-1_amd64.deb -O /tmp/conjur.deb && dpkg -i /tmp/conjur.deb && rm /tmp/conjur.deb


ADD start /start
RUN chmod a+x /start

ENTRYPOINT [ "/start" ]
