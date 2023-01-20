#!/bin/bash

# gracefully stops the ASE server if container is stopped.
shutdown() {
    /home/sybase/bin/ase_stop.sh DB_TEST
}

trap 'shutdown' SIGTERM

. /opt/sap/SYBASE.sh

ret=0
# if database doesn't exist, we create it from our premade package
if [ ! -f "/data/master.dat" ]; then
    cd /
    tar -xzf /tmp/data.tar.gz --no-same-owner
    ret=$?
    cd -
    /home/sybase/bin/ase_start.sh DB_TEST
    $SYBASE/$SYBASE_ASE/bin/charset -Usa -Psybase -SDB_TEST nocase.srt utf8
#     isql -Usa -Psybase -SDB_TEST -J iso_1 << EOF
# sp_configure 'default character set', 190
# go
# EOF
    echo "Restart"
    /home/sybase/bin/ase_stop.sh DB_TEST 
    # sleep 5   
    /home/sybase/bin/ase_start.sh DB_TEST
    # sleep 20
    isql -Usa -Psybase -SDB_TEST -J iso_1 << EOF
sp_configure 'default character set', 190
go
sp_configure 'default sortorder id', 101, 'utf8'
go
sp_configure 'default sortorder id', 101, 'utf8_nocase'
go
EOF
    tail -n 50  $SYBASE/$SYBASE_ASE/install/DB_TEST.log
    echo "Restart 2"
    /home/sybase/bin/ase_stop.sh DB_TEST 
    # sleep 5   
    /home/sybase/bin/ase_start.sh DB_TEST
    echo "STARTING... (about 30 sec)"
    # sleep 30
    while ! grep "SySAM:" $SYBASE/$SYBASE_ASE/install/DB_TEST.log > /dev/null
    do
        echo "Waiting for restart..."
	    sleep 1
    done
    sleep 10
	
    # while [[ $ISDONE -eq 0 ]]; do
    #     echo "Waiting for restart..."
	#     sleep 1
	#     i=$((i+1))
    #     count=$(grep -c "'utf8_nocase'" $SYBASE/$SYBASE_ASE/install/DB_TEST.log)
    #     ISDONE=$?
    # done
    # sleep 20
    /home/sybase/bin/ase_stop.sh DB_TEST     
    # sleep 5   
fi
tail -n 50  $SYBASE/$SYBASE_ASE/install/DB_TEST.log

if [ $ret -ne 0 ]; then
    echo "Error while extracting database files. Exiting."
    exit 1
fi

/home/sybase/bin/ase_start.sh DB_TEST

echo 'Waiting for server to start in order to create the default schema, login and user'

DIR=/docker-entrypoint.d

# convert line endings from dos to unix.
find $DIR -type f -name "*.sql" -exec dos2unix {} +
find $DIR -type f -name "*.sh" -exec dos2unix {} +
# remove leading whitespace/tabs before GO. Otherwise ISQL gives syntax error.
find $DIR -type f -name "*.sql" -exec sed -i 's/^[ \t]*GO/GO/gI' {} +

echo "Executing script in folder $DIR"
for SCRIPT in $DIR/*.sh
do
    if [ -f $SCRIPT -a -x $SCRIPT ]
    then
        $SCRIPT
    else
        echo "The script $SCRIPT is not executable"
    fi
done

echo "Server is ready" > /home/sybase/ready.txt
# Execute the command passed through CMD of the Dockerfile or command when creating a container
exec "$@"

tail -f $SYBASE/$SYBASE_ASE/install/DB_TEST.log
