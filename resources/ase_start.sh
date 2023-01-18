#!/bin/bash
. /opt/sap/SYBASE.sh

SERVER_NAME=$1

echo -en "Starting server \e[0;34m${SERVER_NAME}\e[0m: "

startserver -f $SYBASE/$SYBASE_ASE/install/RUN_${SERVER_NAME} >/dev/null

isql=( isql -Usa -SDB_TEST -Psybase )

for i in {40..0}; do
	if echo 'SELECT 1 go' | "${isql[@]}" &> /dev/null; then
		break;
	fi
	echo 'ASE init process in progress'
	sleep 1
done

# sleep 20
# tail -n 100 $SYBASE/$SYBASE_ASE/install/DB_TEST.log



ret=$?

if [ ${ret} -ne 0 ]; then
    echo -e "\e[0;31mKO\e[0m"
    exit 1
fi

echo -e "\e[0;32mOK\e[0m"
exit 0