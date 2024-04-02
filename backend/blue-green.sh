#!/bin/sh

blue=$(docker --context remote container inspect --format "{{json .State.Health }}" blue-backend | jq -r '.Status') || true
green=$(docker --context remote container inspect --format "{{json .State.Health }}" green-backend | jq -r '.Status') || true
echo $blue
echo $green
if [ $blue == 'healthy' ]; then
    docker --context remote compose --env-file deploy.env up green-backend -d --pull "always" --force-recreate
    while [ $(docker --context remote container inspect --format "{{json .State.Health }}" green-backend | jq -r '.Status') != 'healthy' ]
    do
        sleep 5
    done
    docker --context remote compose stop blue-backend
    docker --context remote container rm -f blue-backend
    echo "Green deployed successfully"
elif [ $green == 'healthy' ]; then
    docker --context remote compose --env-file deploy.env up green-backend -d --pull "always" --force-recreate
    while [ $(docker --context remote container inspect --format "{{json .State.Health }}" blue-backend | jq -r '.Status') != 'healthy' ]
    do
        sleep 5
    done
    docker --context remote compose stop green-backend
    docker --context remote container rm -f green-backend
    echo "Blue deployed successfully"
else
    docker --context remote compose --env-file deploy.env up blue-backend -d --pull "always" --force-recreate
    while [ $(docker --context remote container inspect --format "{{json .State.Health }}" blue-backend | jq -r '.Status') != 'healthy' ]
    do
        sleep 5
    done
    echo "The blue/green strategy is being used for the first time. Blue deployed successfully"
fi