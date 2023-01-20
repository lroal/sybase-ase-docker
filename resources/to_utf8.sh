#!/bin/bash

. /opt/sap/SYBASE.sh

ret=0

/home/sybase/bin/ase_start.sh DB_TEST
$SYBASE/$SYBASE_ASE/bin/charset -Usa -Psybase -SDB_TEST nocase.srt utf8
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
/home/sybase/bin/ase_stop.sh DB_TEST