#!/bin/bash
[ -f .env ]  && source .env
[ ! -z "$1" ] && TARGET="$1"
[ -z "$TARGET" ] && echo "Usage: TARGET=build_target npm run build-static, or set TARGET in .env" && exit 1

echo "Preparing target..."
rm -r $TARGET
mkdir $TARGET
mkdir $TARGET/{tx,arbitrate}

echo "Copying static files..."
cp -r public/{lib,img,lato} $TARGET

echo "Browserifying..."
for file in tx/new tx/join tx/multisig arbitrate/new arbitrate/manage; do
  echo "  - $file"
  browserify -e client/$file.coffee -t coffeeify -t jadeify2 -o $TARGET/$file.js
done

echo "Compiling stylus..."
stylus public/*.styl -o $TARGET

echo "Compiling jade..."
read -d '' LOCALS <<JSON
  {
    "pubkey_address": "${PUBKEY_ADDRESS}",
    "url": "${URL}",
    "api": "${API_URL}"
  }
JSON
jade server/views/*.jade -o $TARGET --obj "$LOCALS"

