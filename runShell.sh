#docker run -t -i --gpus all nvidia-experiment bash
getent group | grep render
getent group | grep video
sudo docker run --restart=unless-stopped  -t -i --gpus all \
	--mount type=bind,source=/shares/video,target=/app \
	--device /dev/dri:/dev/dri \
	--device /dev/dri/renderD128:/dev/dri/renderD128 \
	--device /dev/dri/card0:/dev/dri/card0 \
	--group-add 44 --privileged nvidia-experiment bash
