#!/bin/sh

wget --no-check-certificate -r 'https://drive.google.com/uc?export=download&id=12-r_ur069uKIByyT4BTC2gMFSDf62BKy' -O image_domain.stub

SED=$(which sed)

# check the domain is valid!
PATTERN="^([a-zA-Z0-9](([a-zA-Z0-9-]){0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$"

if [[ "$1" =~ $PATTERN ]]; then
  DOMAIN=$(echo $1 | tr '[A-Z]' '[a-z]')
  echo "---> Creating hosting for:" $DOMAIN
else
  echo "---> invalid domain name"
  exit 1
fi

CONFIG="$DOMAIN"

cp image_domain.stub $CONFIG
$SED -i "s/{{DOMAIN}}/$DOMAIN/g" $CONFIG

echo "---> The subdomain has been successfully generated"

cp $CONFIG "/etc/nginx/sites-available"
ln -s "/etc/nginx/sites-available/$DOMAIN" "/etc/nginx/sites-enabled"
sudo systemctl restart nginx;
sudo certbot --nginx --register-unsafely-without-email --redirect -d $DOMAIN
sudo systemctl status certbot.timer
sudo certbot renew --dry-run

rm -f image_nginx_generator.sh
rm -f image_domain.stub
rm -f $DOMAIN
systemctl status nginx;
echo "---> The subdomain has been moved to nginx to sites-available and symlinked to sites-enabled"
