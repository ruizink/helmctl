#!/usr/bin/env bash

# set docker image tags from git commit info
set_tags_from_git() {
    git_sha=$(git rev-parse HEAD)
    version_tag=$(git describe --tags --exact-match "${git_sha}" 2>/dev/null) || true
    IMAGE_TAG_SHA="${git_sha}"
    IMAGE_TAG_VERSION="${version_tag}"
}

# check if the repo is not dirty
check_not_dirty() {
    dirty=$(git status --porcelain)
    if [ -n "${dirty}" ]; then
        echo "Please commit git changes before pushing to a registry"
        return 1
    fi
}

docker_login() {
    echo "${DOCKER_PASSWORD}" | docker login -u "${DOCKER_USERNAME}" --password-stdin
}

# push a docker image
docker_push() {
    image_name=$1
    docker push "${image_name}"
    echo "Image ${image_name} pushed to remote"
}

# tag a docker image
docker_tag() {
    image_name=$1
    image_tag=$2
    docker tag "${image_name}" "${image_tag}"
    echo "Image ${image_name} tagged as ${image_tag} to remote"
}

# build a docker image
docker_build() {
    image_name=$1
    tag=${2:-latest}
    docker build . -t "${image_name}:${tag}"
    echo "Image ${image_name}:${tag} built"
}


set -e

if [ -n "${IMAGE_NAME}" ]; then
    docker_build "${IMAGE_NAME}"
    # if CONTAINER_REGISTRY is set, add more tags to the image and push it
    if [ -n "${CONTAINER_REGISTRY}" ]; then
        check_not_dirty

        docker_login

        set_tags_from_git

        # push image with tag latest
        docker_tag "${IMAGE_NAME}:latest" "${CONTAINER_REGISTRY}/${IMAGE_NAME}:latest"
        docker_push "${CONTAINER_REGISTRY}/${IMAGE_NAME}:latest"

        # push image with the commit sha
        docker_tag "${IMAGE_NAME}:latest" "${CONTAINER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG_SHA}"
        docker_push "${CONTAINER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG_SHA}"

        # if IMAGE_TAG_VERSION is set, tag and push it
        if [ -n "${IMAGE_TAG_VERSION}" ]; then
            docker_tag "${IMAGE_NAME}:latest" "${CONTAINER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG_VERSION}"
            docker_push "${CONTAINER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG_VERSION}"
        else
            echo "Couldn't find a git tag for the commit ${IMAGE_TAG_SHA}. Skipping version tagging..."
        fi
    fi
else
    echo "Environment variable IMAGE_NAME not set"
    exit 2
fi