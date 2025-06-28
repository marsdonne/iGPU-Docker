# ROCm Docker for 780M

Run with

``sh
docker run -it --rm \
--device=/dev/kfd \
--device=/dev/dri \
--group-add=$(getent group render | cut -d: -f3) \
--group-add=$(getent group video | cut -d: -f3) \
<your-docker-image-name>
``
