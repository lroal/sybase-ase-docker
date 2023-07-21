#!/bin/bash

# gracefully stops the ASE server if container is stopped.
shutdown() {
    /home/sybase/bin/ase_stop.sh DB_TEST
}

trap 'shutdown' SIGTERM

. /opt/sap/SYBASE.sh

if [ ! -f "/data/master.dat" ]; then
    cd /
    tar -xzf /tmp/data.tar.gz --no-same-owner
    cd -
fi

/home/sybase/bin/ase_start.sh DB_TEST

echo 'Waiting for server to start'

DIR=/docker-entrypoint.d

# convert line endings from dos to unix.
find $DIR -type f -name "*.sql" -exec dos2unix {} +
find $DIR -type f -name "*.sh" -exec dos2unix {} +
# remove leading whitespace/tabs before GO. Otherwise ISQL gives syntax error.
find $DIR -type f -name "*.sql" -exec sed -i 's/^[ \t]*GO/GO/gI' {} +

echo "Executing script in folder $DIR"

shopt -s nullglob
for SCRIPT in $DIR/*.sh; do
    if [ -f $SCRIPT -a -x $SCRIPT ]
    then
        $SCRIPT
    else
        echo "The script $SCRIPT is not executable"
    fi
done

# Execute the command passed through CMD of the Dockerfile or command when creating a container
exec "$@"

tail -f $SYBASE/$SYBASE_ASE/install/DB_TEST.log
