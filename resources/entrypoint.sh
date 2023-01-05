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
    $SYBASE/$SYBASE_ASE/bin/charset -Usa -Psybase -SDB_TEST binary.srt utf8
    isql -Usa -Psybase -SDB_TEST -J iso_1 << EOF
sp_configure 'default character set', 190
go
sp_configure 'default sortorder id', 50
go
EOF
    /home/sybase/bin/ase_stop.sh DB_TEST    
    /home/sybase/bin/ase_start.sh DB_TEST
    i=0
    ISDONE=0
    echo "STARTING... (about 30 sec)"
    while [[ $ISDONE -eq 0 ]] || [[ $i -lt 30 ]]; do
        echo "Waiting for restart..."
	    sleep 1
	    i=$((i+1))
        count=$(grep -c "'bin_utf8'" $SYBASE/$SYBASE_ASE/install/DB_TEST.log)
        ISDONE=$?
    done
fi

if [ $ret -ne 0 ]; then
    echo "Error while extracting database files. Exiting."
    exit 1
fi

/home/sybase/bin/ase_start.sh DB_TEST

echo 'Waiting for server to start in order to create the default schema, login and user'

tail -n -f $SYBASE/$SYBASE_ASE/install/DB_TEST.log
