FROM ubuntu:22.04

RUN apt update && apt install -y wget gnupg unzip
RUN wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | gpg --dearmor | tee /usr/share/keyrings/mongodb.gpg > /dev/null \
    && echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-6.0.list
RUN apt update && apt -y install mongodb-org

COPY ./run.sh .
RUN chmod +x run.sh
CMD ["/run.sh"]
