FROM debian:stable

RUN apt update -y                              \
    && apt upgrade -y                          \
    && apt install -y build-essential valgrind

COPY valgrind.bash /root/valgrind.bash

ENTRYPOINT [ "/root/valgrind.bash" ]
