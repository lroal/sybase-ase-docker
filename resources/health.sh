#!/bin/bash

. /opt/sap/SYBASE.sh

isql -Usa -Psybase -SDB_TEST -J utf8 --retserverror << EOF
SELECT 1 as foo
go
EOF

if [ $? -ne 0 ]; then
  exit 1
fi
