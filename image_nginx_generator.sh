#!/bin/sh

SED=$(which sed)

# check the domain is valid!
PATTERN="^([a-zA-Z0-9](([a-zA-Z0-9-]){0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$"

if [[ "$1" =~ $PATTERN ]]; then
  DOMAIN=$(echo $1 | tr '[A-Z]' '[a-z]')
  echo "Creating hosting for:" $DOMAIN
else
  echo "invalid domain name"
  exit 1
fi

CONFIG="$DOMAIN"

cp image_domain.stub $CONFIG
$SED -i "s/{{DOMAIN}}/$DOMAIN/g" $CONFIG

echo "The subdomain has been successfully generated"

cp $CONFIG "/etc/nginx/sites-available"
ln -s "/etc/nginx/sites-available/$DOMAIN" "/etc/nginx/sites-enabled"

sudo certbot --nginx --redirect -d $DOMAIN

echo "The subdomain has been moved to nginx to sites-available and symlinked to sites-enabled"