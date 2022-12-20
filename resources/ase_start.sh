#!/bin/bash
. /opt/sap/SYBASE.sh

SERVER_NAME=$1

echo -en "Starting server \e[0;34m${SERVER_NAME}\e[0m: "

startserver -f $SYBASE/$SYBASE_ASE/install/RUN_${SERVER_NAME} >/dev/null
sleep 5
$SYBASE/$SYBASE_ASE/bin/charset -Usa -Psybase -S${SERVER_NAME} binary.srt utf8

cat <<-EOSQL > init1.sql
use master
go
sp_configure 'default sortorder id', 50, 'utf8'
go
EOSQL
 
$SYBASE/$SYBASE_ASE/bin/isql -Usa -Psybase -S{SERVER_NAME}  -i"./init1.sql"

startserver -f $SYBASE/$SYBASE_ASE/install/RUN_${SERVER_NAME} >/dev/null

ret=$?

if [ ${ret} -ne 0 ]; then
    echo -e "\e[0;31mKO\e[0m"
    exit 1
fi

echo -e "\e[0;32mOK\e[0m"
exit 0