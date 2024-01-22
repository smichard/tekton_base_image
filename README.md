# Custom Tekton Tasks and Base Image Repository

This repository hosts the Dockerfile for building a base image designed for Tekton tasks, along with a collection of custom Tekton tasks. The base image is built on alpine:3.19.0 and includes essential tools like curl, git, and openssh-client.

[![GitHub Tag](https://img.shields.io/github/v/tag/smichard/tekton_base_image "GitHub Tag")](https://github.com/smichard/tekton_base_image/tags)
[![GitHub pull requests](https://img.shields.io/github/issues-pr-raw/smichard/tekton_base_image "GitHub Pull Requests")](https://github.com/smichard/tekton_base_image/pulls)
[![Container Registry on Quay](https://img.shields.io/badge/Quay-Container_Registry-46b9e5 "Container Registry on Quay")](https://quay.io/repository/michard/tekton_base_image)
[![Start Dev Space](https://www.eclipse.org/che/contribute.svg)](https://devspaces.apps.ocp.michard.cc#https://github.com/smichard/tekton_base_image)

## Table of Contents
- [Introduction](#introduction)
- [Getting Started](#getting-started)
- [Base Image Details](#base-image-details)
- [Custom Tekton Tasks](#custom-tekton-tasks)
- [Building the Base Image](#building-the-base-image)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

## Introduction

This project aims to provide a lightweight and efficient base image for Tekton tasks, along with a suite of custom Tekton tasks designed to streamline CI/CD pipelines. The base image is optimized for performance and size, making it ideal for use in Kubernetes and Tekton environments.

## Getting Started

To use this repository, ensure you have Podman / Docker installed and running on your machine. Clone this repository to get started with the custom Tekton tasks and the base image:

```bash
git clone https://github.com/smichard/tekton_base_image
cd tekton_base_image
```

## Base Image Details

The Dockerfile in this repository creates a base image using alpine:3.19.0. This image includes:

- **curl:** For transferring data from or to a server.
- **git:** For source code management.
- **openssh-client:** For secure shell operations.


## Building the Base Image

To build the container image, run the following command in the root directory of this repository:

```bash
podman build -t tekton-base-image .
```

## Usage

After building the image, it can be used as a base image in Tekton tasks. Refer to the Tekton documentation for how to specify a custom image in your task definitions.

## Contributing
Contributions to this project are welcome. Please ensure that your contributions adhere to the following guidelines:

- Write clear and descriptive commit messages.
- Create a new branch for each feature or bug fix.
- Ensure the build passes before submitting a pull request.

## License

This project is licensed under the [MIT License](./LICENSE). See the LICENSE file for more details.
