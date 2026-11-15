#!/bin/bash
set -o pipefail

export ARCH=$(uname -m)
export COMPOSE_PROFILES=$ARCH


#Define colors for ease of use
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RESET_CLR="\033[0m"


report_ok(){
    echo -e "
Postoffice download status: $DL_1

${YELLOW}!!! WARNING!!!${RESET_CLR}
Make sure you customized the compose.yml according to your needs. You can choose to:\n
\t1. Stop now, customize the configurations to your likings and build the containers later\n
\t2. Continue with the current configurations.\n"

    sleep 3
}

report_error(){
    echo -e "
Postofffice download status: $DL_1

$GET_POSTOFFICE_MSG\n
$GET_AEMU_MSG\n
Some errors were encountered. The process is going to stop as the requirements to run the containers might not be satisfied. Check the logs fix the issues and then run 'ARCH=\$(uname -m) COMPOSE_PROFILES=\$(uname -m) docker compose up -d --build' to start the process.\n\n
${YELLOW}!!! WARNING!!!${RESET_CLR}
Remember to customize the compose.yml depending on your need."

    sleep 2
}


bring_up(){
    #Building the images
    echo -e "Starting the build process. Detected architecture: ${ARCH}"
    if ! docker compose build --no-cache
    then
        echo -e "An error occurred during the build. Check the logs in ./logs/bring-up.log"
        exit 1
    fi

    #Staring the containers
    echo -e "Starting the containers\n"
    if ! docker compose up -d
    then
        echo -e "An error occurred while starting the services. Check the logs in ./logs/bring-up.log"
        exit 1
    fi

    # Bring-up finished
    echo -e "${GREEN}Completed!${RESET_CLR}"
}


check_logdir(){
    if [ -d ./logs ]
    then
        echo "Removing old logs if present"
        rm -v ./logs/*
    else
        mkdir -v ./logs
    fi
}


check_logdir 2>&1 | tee -a ./logs/init.log

./get-postoffice.sh 2>&1 | tee ./logs/get-postoffice.log
GET_POSTOFFICE_EXIT_CODE=$?
if [ $GET_POSTOFFICE_EXIT_CODE != 0 ]
then
    GET_POSTOFFICE_MSG="An error occurred while downloading aemu_postoffice. Try to run the script 'get-postoffice.sh' again or download it manually.\nFor more details, check the logs './logs/get-postoffice.log'."
    DL_1="ERROR"
else
    DL_1="OK"
fi


if [ "$DL_1" = "OK" ]
then
    report_ok 2>&1 | tee -a ./logs/init.log
    read -p "Chose how to proceed (1,2):" option
    case $option in
        1)
            echo -e "User chose option 1\nWhen you're ready, run the following command:\n\t'ARCH=\$(uname -m) COMPOSE_PROFILES=\$(uname -m) docker compose up -d --build'" | tee -a ./logs/init.log
            sleep 1
            exit 0
            ;;
        2)
            echo -e "User chose option 2\nStaring the build process..." | tee -a ./logs/init.log
            bring_up 2>&1 | tee -a ./logs/bring-up.log
            if [ $? != 0 ]
            then
                echo -e "ERROR: Something went wrong. Check the logs for more details" | tee -a ./logs/init.log
                exit 1
            else
                echo -e "The bring-up is finished\n\nBefore making changes to the files used by aemu_postoffice, I suggest you to make sure you understand the implications." | tee -a ./logs/init.log
                exit 0
            fi
            ;;
        *)
            echo "Choose between option 1 and 2."
            ;;
    esac
else
    report_error 2>&1 | tee -a ./logs/init.log
    exit 1
fi