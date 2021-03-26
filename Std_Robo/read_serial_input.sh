#!/bin/bash

while getopts ":d:" opt; do
    case "${opt}" in
        d) ard_port=${OPTARG} ;;
        *) echo "Please use the -d tag to pass through arduino port" ;;
    esac
done

if [ "${ard_port}" ]; then
    cat ${ard_port}
fi
echo "Please use the -d tag to pass through arduino port"
