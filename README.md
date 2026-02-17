# Repository used to build the container hosting the relay server and the status web page

Cmponents used:

- [aemu_postoffice](https://github.com/Kethen/aemu_postoffice) by GitHub user [Kethen](https://github.com/Kethen) as an ad-hoc relay server - PDP flow
- [aemu](https://github.com/Kethen/aemu) by GitHub user [Kethen](https://github.com/Kethen) for the peer discovery via the adhoctl server - PTP flow

## Features

- Automated download of the release tagged as latest (get-aemu.sh and get-postoffice.sh)

- Separated containers for each service (eg. you don't want to restart the main relay server components just to apply some changes to the status webpage)

- Fully automated deploy with little manual changes needed (using the init.sh)

- Semiautomated deeply with the use of get-aemu.sh and get-postoffice.sh and the compose.yml


## How it works

Clone the repository or download the zip.
You can choose to build a docker image that you will use to host a room in two way:

- **clone the repo and run `./init.sh`**: it's going to create log files, making troubleshooting easier. It assumes that some requisites can be satisfied (eg. a docker network with the CIDR 172.20.0.0/24 can be created)

- **clone the repo and initialize manually**: if you prefer more controll over every single step of the process.



### Deploy using init.sh

STEP 1: clone the repository and, from there, run the init.sh


STEP 2 (optional but recommended): make the data from postoffice available by editing the file the server.js, changing the loopback address 127.0.0.1 with 172.20.0.11 (address of the postemu container if using the default configuration) and restarting the webserver container.


STEP 3 (optional): remove unnecessary files (eg. all the client files for the PSP)

Note: in the future I'll release a version of the scripts that take care of the last 2 steps.


### Semiautomated deploy

STEP 1: clone the repository and, from there, start by running:



```

./get-postoffice.sh

```
AND

```

./get-aemu.sh

```

STEP 2 (optional but recommend): edit the server.js file and change the loopback address 127.0.0.1 with 172.20.0.11 (assuming you are using the default compose.yml file)


STEP 3: build the images and start the containers using:

a. ignoring cache

```

docker compose build --no-cache && \
docker compose up -d

```
OR

b. using cache if available

```
docker compose up -d --build

```


STEP 4 (optional): remove unnecessary files (eg. all the client files for the PSP)