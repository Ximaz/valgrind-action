FROM debian:stable

RUN apt update -y          \
    && apt upgrade -y      \
    && apt install -y build-essential valgrind

WORKDIR /root/

COPY valgrind.sh /root/valgrind.sh

ENTRYPOINT [ "/root/valgrind.sh" ]
