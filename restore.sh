#!/bin/sh

# set environment variables
MYSQL_HOST=db
MYSQL_USER=root
MYSQL_PASSWORD=example
MYSQL_DATABASE=example
BACKUP_FILE=$1

# prompt receive backup file name and store to $BACKUP_FILE
# read -p "Enter backup file name: " BACKUP_FILE
echo "Backing up $BACKUP_FILE"

# untar backup file to temp folder
docker run -d --rm --name RESTORE_CONTAINER_UNTAR \
    -v $PWD/local_backups:/backup \
    -v $PWD/temp:/temp \
    alpine tar -C /temp -xvf /backup/$BACKUP_FILE && \

# perform mysql restore
docker run -d --name RESTORE_CONTAINER_EXECUTE -v $PWD/temp:/backup --network=lab mysql:8 
docker exec -i RESTORE_CONTAINER_EXECUTE mysql -h$MYSQL_HOST -u$MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE < $PWD/temp/backup/dump.sql
docker stop RESTORE_CONTAINER_EXECUTE
docker rm RESTORE_CONTAINER_EXECUTE

# remove temp folder
# rm -rf $PWD/temp
