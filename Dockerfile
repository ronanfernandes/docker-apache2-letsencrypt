FROM enoniccloud/apache2

MAINTAINER Erik Kaareng-Sunde <esu@enonic.com>

RUN rm /etc/apache2/sites-enabled/000-default.conf
RUN rm /etc/apache2/sites-enabled/default-ssl.conf


COPY index.html /var/www/html/index.html
COPY launcher.sh /usr/local/bin/launcher.sh
RUN chmod +x /usr/local/bin/launcher.sh

CMD /usr/local/bin/launcher.sh
