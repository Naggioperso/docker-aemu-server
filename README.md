# Repository used to build the container hosting the relay server and the status web page

Components used:
- [aemu_postoffice](https://github.com/Kethen/aemu_postoffice) by [Kethen](https://github.com/Kethen). The new C++ version will be used.

## Features
- Support for both x86 and ARM architectures: if ARM architecture is detected, the process will take care of cloning [aemu_postoffice](https://github.com/Kethen/aemu_postoffice) and its dependencies, and building the executable.
- Automated download of the release tagged as latest via `get-postoffice.sh`.
- Fully automated deployment with few manual changes needed via `init.sh`.
- Semi-automated deployment using `get-postoffice.sh` and `compose.yml`.

## How it works
Clone the repository or download the zip. You can customize it a little bit before running the scripts so that it satisfies your requirements. You can choose to build a Docker image to host the server in two ways:
- **Clone the repo and run `./init.sh`**: This creates log files, making troubleshooting easier. It assumes that certain prerequisites are satisfied, such as the default Docker network being available. Change it in `compose.yml` if it is not.
- **Clone the repo and initialize manually**: Choose this option if you prefer more control over every single step of the process.

## Requirements
1. Run as the root user unless you installed Docker following ["Rootless mode"](https://docs.docker.com/engine/security/rootless/).
2. Make sure that the required software is installed:

**DEB-based**
```bash
apt install curl wget git unzip jq
```

**RPM-based**
- Fedora, Oracle Linux, AlmaLinux, etc.
```bash
dnf install curl wget git unzip jq
```
- SUSE/openSUSE
```bash
zypper in curl wget git unzip jq
```

## Deploy using init.sh
- **STEP 1**: Clone the repository or download the zip. Once you have cloned the repo or extracted the zip, move inside the folder and run `./init.sh`.
- **STEP 2** (optional): Remove unnecessary files (e.g., all the client files for the PSP).
- **STEP 3** (optional): Configure SSL to make the web page reachable via HTTPS.
- **STEP 4** (optional): Customize the values of `config.json` in the `server_cpp` folder. **EDIT ONLY IF YOU KNOW WHAT YOU'RE DOING.**

## Semi-automated deploy
- **STEP 1**: Clone the repository and, from there, start by running:
```bash
./get-postoffice.sh
```
- **STEP 2**: Build the images and start the containers using:

  a. Ignoring cache (recommended)
  ```bash
  export ARCH=\$(uname -m)
  export COMPOSE_PROFILES=\$ARCH
  docker compose build --no-cache && \
  docker compose up -d
  ```
  OR
  
  b. Using cache if available
  ```bash
  docker compose up -d --build
  ```
- **STEP 3** (optional): Remove unnecessary files (e.g., all the client files for the PSP).
- **STEP 4** (optional): Configure SSL to make the web page reachable via HTTPS.
- **STEP 5** (optional): Customize the values of `config.json` in the `server_cpp` folder. **EDIT ONLY IF YOU KNOW WHAT YOU'RE DOING.**
