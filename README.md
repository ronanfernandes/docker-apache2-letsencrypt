# Apache2 with Let's Encrypt
This is a apache2 docker image with letsencrypt implemented.
Before starting the apache2 deamon, this image will check if certificates for
the hostname domain exist.
If certifacates exists, it will do a `certbot renew` command to check if
the certificates needs a renewal and renew it if needed.

In the case that certifacates do not exist, it will create it for the domains
in the environment variable `LETS_ENCRYPT_DOMAINS`
with the email in the `LETS_ENCRYPT_EMAIL` variable as the Let's Encrypt
registration and recovery contact.
The environment variable `LETS_ENCRYPT_DOMAINS` can be a comma separated list
of domains that should be in the certificate.


## Setup

### Setting up with docker
You can specify the variables
```
docker run -d -v /etc/letsencrypt -v /var/lib/letsencrypt --name letsencryptstore busybox

docker run -d --volumes-from letsencryptstore --restart always \
  -e LETS_ENCRYPT_EMAIL="your@email.com" \
  -e LETS_ENCRYPT_DOMAINS="yourserver.com,site2.yourserver.com" \
  -p "80:80" -p "443:443" \
  --name apache2 enoniccloud/apache2-letsencrypt
```

### Setting up with docker-compose
There are multiple ways of setting up a docker-compose, here is an example of how to set it up with custom configuration.
- Add the following code to your docker-compose setup:
```
apache2:
  build: apache2
  hostname: www.yourserver.com
  restart: always
  volumes_from:
    - letsencryptstore
  ports:
    - "80:80"
    - "443:443"
  environment:
    LETS_ENCRYPT_EMAIL: "your@email.com"
    LETS_ENCRYPT_DOMAINS: "yourserver.com,site2.yourserver.com"
  labels:
    io.enonic.backup.data: "/etc/letsencrypt,/var/lib/letsencrypt"
letsencryptstore:
  image: busybox
  volumes:
    - "/etc/letsencrypt"
    - "/var/lib/letsencrypt"
```
- Create the folder `apache2` in your docker-compose setup
- Add a vhost config file like this.
```
<VirtualHost *:80>
    ServerName your.host.com
    DocumentRoot /var/www/html/

    #RewriteEngine on
    #RewriteRule ^/(.*) https://your.host.com/$1 [L,R=301]

</VirtualHost>

<VirtualHost *:443>
    ServerName your.host.com
    DocumentRoot /var/www/html/
    SSLEngine on
    SSLProtocol all -SSLv2 -SSLv3
    SSLCipherSuite ALL:!ADH:!EXPORT:!SSLv2:!RC4:!RC4+RSA:!EDH-RSA-DES-CBC-SHA:!DES-CBC3-SHA:!DES-CBC-SHA:!ECDHE-RSA-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:+HIGH:+MEDIUM:+LOW
    SSLCertificateFile /etc/letsencrypt/certs/cert.pem
    SSLCertificateKeyFile /etc/letsencrypt/certs/privkey.pem
    SSLCertificateChainFile /etc/letsencrypt/certs/chain.pem
    SetEnvIf User-Agent ".*MSIE.*" nokeepalive ssl-unclean-shutdown

</VirtualHost>

```
- And add a `Dockerfile` that Uses the `enoniccloud/apache2-letsencrypt` image, adds the vhost file you made and other modifications to your setup.
```
FROM enoniccloud/apache2-letsencrypt

COPY myvhost.conf /etc/apache2/sites-enabled/myvhost.conf

```

## Troubleshooting
The most common problem happens when this is run the first time and the user can
make a input mistake (like wrong domain name etc.). And fixing it may not
remove the old certificate with mistakes in it. Just delete everything in 
/etc/letsencrypt/
