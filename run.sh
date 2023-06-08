#!/bin/bash

error() {
  echo -e "\e[91m$1\e[m"
  exit 0
}
success() { echo -e "\e[92m$1\e[m"; }

if [ -z "${TOKEN}" ]; then
  error "Missing download token."
fi

if [ -z "${MONGODB_PASSWORD}" ]; then
  error "Missing MongoDB password."
fi

if [ ! -d ./tmp ]; then
  echo -n "Create temporary directory.......................... "
  mkdir ./tmp
  if [ ! -d ./tmp ]; then
    error "[ERROR]"
  fi

  success "[OK]"
fi

echo -n " > Downloading database "
wget -q -O ./tmp/database.zip "http://www.ip2location.com/download?token=${TOKEN}&productcode=DB5LITE"
if [ ! -f ./tmp/database.zip ]; then
 error "[DOWNLOAD FAILED]"
fi

if grep -q 'NO PERMISSION' ./tmp/database.zip; then
 error "[DENIED]"
fi

if grep -q '5 TIMES' ./tmp/database.zip; then
 error "[QUOTA EXCEEDED]"
fi

if [ "$(wc -c <./tmp/database.zip)" -lt 512000 ]; then
 error "[FILE CORRUPTED]"
fi

success "[OK]"

echo -n " > Decompressing downloaded package "
unzip -q -o ./tmp/database.zip -d ./tmp
CSV="$(find ./tmp -name 'IP2LOCATION*.CSV')"
if [ -z "$CSV" ]; then
  error "[ERROR]"
fi

success "[OK]"

echo -n " > Creating directories for MongoDB data and logs "
if ! mkdir -p ./data/db; then
  error "[ERROR]"
fi

if ! mkdir -p ./log; then
  error "[ERROR]"
fi

success "[OK]"

echo -n " > [MongoDB] Start daemon "
if ! mongod --fork --logpath ./log/mongod.log --port 27017 --dbpath ./data/db; then
  error "[ERROR]"
fi

success "[OK]"

echo -n " > [MongoDB] Create admin user "
mongosh --port 27017 <<EOF
use admin
db.createUser(
  {
    user: "myUserAdmin",
    pwd: "$MONGODB_PASSWORD",
    roles: [
      { role: "userAdminAnyDatabase", db: "admin" },
      { role: "readWriteAnyDatabase", db: "admin" }
    ]
  }
)
EOF

echo -n " > [MongoDB] Shut down daemon "
if ! mongod --shutdown; then
  error "[ERROR]"
fi

success "[OK]"

echo -n " > [MongoDB] Start daemon with authentication "
if ! mongod --fork --logpath ./log/mongod.log --port 27017 --dbpath ./data/db --auth --bind_ip_all; then
  error "[ERROR]"
fi

success "[OK]"

echo -n " > [MongoDB] Creating collection \"iplocationstmp\" and importing data "
mongoimport -u myUserAdmin -p "$MONGODB_PASSWORD" --authenticationDatabase admin --db ip2locationdb --drop --collection iplocationstmp --type csv --file "$CSV" --fields ipFrom,ipTo,countryCode,countryName,regionName,cityName,latitude,longitude

echo -n " > [MongoDB] Creating index "
mongosh -u myUserAdmin -p "$MONGODB_PASSWORD" --authenticationDatabase admin <<EOF
use ip2locationdb
db.iplocationstmp.createIndex({ipFrom: 1})
EOF

echo -n " > [MongoDB] Renaming collection \"ip2locationstmp\" to \"ip2locations\" "
mongosh -u myUserAdmin -p "$MONGODB_PASSWORD" --authenticationDatabase admin <<EOF
use ip2locationdb
db.iplocationstmp.renameCollection("ip2locations", true)
EOF

echo " > Setup completed"

rm -rf ./tmp

tail -f /dev/null
