#!/bin/bash


#Define colors for ease of use
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RESET_CLR="\033[0m"


report_ok(){
    echo -e "
Postoffice download status: $DL_1
Aemu download status: $DL_2\n
${YELLOW}!!! WARNING!!!${RESET_CLR}
The webserver is running in it's own container to make it independent from the main components. The default webserver uses the localhost address (127.0.0.1) to fetch data for the status page, therefore, it will not work unless you edit the server.js, substituting the localhost with the IP of the container running the postoffice software. You can choose to:\n
\t1. Stop now, customize the configurations to your likings and build the containers later\n
\t2. Continue with the default configurations and apply the customizations later.\n"

    sleep 5
}

report_error(){
    echo -e "
Postofffice download status: $DL_1
$GET_POSTOFFICE_MSG\n
Aemu download status: $DL_2
$GET_AEMU_MSG\n
Some errors were encountered. The process is going to stop as the requirements to run the containers might not be satisfied. Check the logs fix the issues and then run 'docker compose up -d --build' to start the process.\n\n
${YELLOW}!!! WARNING!!!${RESET_CLR}
The webserver exposing the status page will run in it's own container to make it independent from the main components. The default webserver uses the localhost address (127.0.0.1) to fetch data for the status page, therefore, it will not work unless you edit the server.js, substituting the localhost with the IP of the container running the postoffice software."
    
    sleep 2
}


bring_up(){
    #Building the images
    echo "Starting to build the custom images\n"
    if ! docker compose build
    then
        echo -e "An error occurred during the build of the images. Check the logs in ./logs/bring-up.logs"
        exit 1
    fi

    #Staring the containers
    echo "Starting the containers\n"
    if ! docker compose up -d
    then
        echo -e "An error occurred during the start of the containers. Check the logs in ./logs/bring-up.logs"
        exit 1
    fi

    # Bring-up finished
    echo -e "Comlpeted!"
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
    GET_POSTOFFICE_MSG="An error occurred during tha download of postoffice. Try to run the scritp 'get-postoffice.sh' again or download it manually.\nFor more details, check the logs './logs/get-postoffice.log'."
    DL_1="ERROR"
else
    DL_1="OK"
fi

./get-aemu.sh 2>&1 | tee ./logs/get-aemu.log
GET_AEMU_EXIT_CODE=$?
if [ $GET_AEMU_EXIT_CODE != 0 ]
then
    GET_AEMU_MSG="An error occurred during tha download of aemu. Try to run the scritp 'get-aemu.sh' again or download it manually.\nFor more details, check the logs './logs/get-aemu.log'."
    DL_2="ERROR"
else
    DL_2="OK"
fi


if [ "$DL_1" = "OK" ] && [ "$DL_2" = "OK" ]
then
    report_ok 2>&1 | tee ./logs/init.log
    read -p "Chose how to proceed (1,2):" option
    case $option in
        1)
            echo "User chose option 1\nWhen you're ready, run the following command:\n\t'docker compose up -d --build'" | tee -a ./logs/init.log
            sleep 1
            exit 0
            ;;
        2)
            echo -e "User chose option 2\nStaring the build process..." | tee -a ./logs/init.log
            bring_up 2>&1 | tee -a ./logs/bring-up.logs
            echo -e "The bring-up is finished\n\nChanging the IP in the server.js file will only require the restart of the the webserver with 'docker compose restart websrv'. Before making further changes, I suggest you to make sure you understand the implications." | tee -a ./logs/init.log
            exit 0
            ;;
        *)
            echo "Choose between option 1 and 2."
            ;;
    esac
else
    report_error 2>&1 | tee -a ./logs/init.log
    exit 1
fi