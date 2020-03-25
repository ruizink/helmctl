CONTAINER_REGISTRY=docker.io
IMAGE_NAME=ruizink/helmctl

build:
	IMAGE_NAME=${IMAGE_NAME} sh ./build.sh

publish:
	IMAGE_NAME=${IMAGE_NAME} CONTAINER_REGISTRY=${CONTAINER_REGISTRY} sh ./build.sh