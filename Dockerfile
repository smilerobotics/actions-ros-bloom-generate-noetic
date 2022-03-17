FROM ros:noetic-ros-base

COPY main.sh /main.sh

ENTRYPOINT [ "/main.sh" ]
