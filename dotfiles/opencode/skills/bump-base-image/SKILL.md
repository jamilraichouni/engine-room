---
name: bump-base-image
description: >-
  Identifies latest alpine image in Docker registry located at
  ato-c-docker-stage-local.bahnhub.tech.rz.db.de. The latest image is
  identified running the command `skopeo list-tags
  docker://db-container-lib-docker-release-local.bahnhub.tech.rz.db.de/alpine`.
  The command output is used to update the Dockerfile so that the base image
  derives from the latest alpine image. This skill shall be used when the user
  asks to bump the base image to the latest available alpine image.
compatibility: >-
  Requires OpenCode, bash, skopeo, and access to Artifactory registry
---

# Skill: Bump base image to latest alpine image

## Step-by-step instructions

- Login to the Artifactory registry using
  `docker login dbb-set-docker-stage-dev-local.bahnhub.tech.rz.db.de` with
  username (`jamilraichouni`) and token stored in environment variable
  `ARTIFACTORY_ATOC_DOCKER_STAGE_PAT`.
- Run the command
  `skopeo list-tags docker://db-container-lib-docker-release-local.bahnhub.tech.rz.db.de/alpine`
  to get the list of available alpine images.
- Identify the latest alpine image from the command output and print the image
  tag
- Update the Dockerfile to use the latest alpine image as the base image
