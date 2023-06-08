# IP2Location MongoDB Docker Image

This repository contains a Dockerfile and a shell script for setting up an IP2Location MongoDB database. The script downloads the IP2Location database, decompresses it, sets up a MongoDB instance, and imports the data into a collection.

## Prerequisites

Before running the project, make sure you have the following:

- Docker installed on your system.

## Usage

Follow the steps below to run the IP2Location MongoDB project:

1. Pull the Docker image from the GitHub Container Registry:

   ```shell
   docker pull ghcr.io/casantosmu/docker-ip2location-mongodb:main
   ```

2. Build the Docker image locally:

   ```shell
   docker build -t ip2location-mongodb .
   ```

3. Run the Docker container:

   ```shell
   docker run -d --name ip2location-mongodb \
   -e TOKEN=${TOKEN} \
   -e MONGODB_PASSWORD=${MONGODB_PASSWORD} \
   --network ip2location-mongodb \
   ip2location-mongodb
   ```

   Make sure to replace `${TOKEN}` and `${MONGODB_PASSWORD}` with the appropriate values.

4. Wait for the setup to complete. Once the setup is done, you can use the IP2Location database in your MongoDB instance.

## Acknowledgements

- [IP2Location](http://www.ip2location.com/) - Provider of IP geolocation data.
