#!/bin/bash

if [[ $# != 6 ]]
 echo "Execute the script as follows:"
 echo "Usage: ./<Script Name> <Database User> <Database Name> <S3 Bucket Name> <No. of old dumps to retain> <Dump File Name> <S3 dump path>"
 exit 0
fi

DB_USER=$1
DB_NAME=$2
S3_BUCKET_NAME=$3
OLD_DUMPS_COUNT=$4
DUMP_FILE_NAME=$5
S3_DUMP_PATH=$6

TIMESTAMP=$(date +"%d-%b-%Y-%H-%M-%S")
S3BUCKET="s3://$S3_BUCKET_NAME"

# Dump of PostgreSQL using pg_dump. Ensure that pg_dump path is added in the environment

pg_dump -U $DB_USER -F t $DB_NAME > $DUMP_FILE_NAME

# Deleting old dump files older than $OLD_DUMPS_COUNT days

find  $S3_DUMP_PATH/*   -mtime +$OLD_DUMPS_COUNT   -exec rm  {}  \;

# Storing latest backup on S3

s3cmd   put   --recursive   $S3_DUMP_PATH/*   $S3_BUCKET_NAME
