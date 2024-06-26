sybinit.release_directory: USE_DEFAULT
sybinit.product: sqlsrv
sqlsrv.server_name: DB_TEST
sqlsrv.sa_password: sybase
sqlsrv.sort_order: USE_DEFAULT
sqlsrv.default_characterset: USE_DEFAULT
sqlsrv.new_config: yes
sqlsrv.do_add_server: yes
sqlsrv.network_protocol_list: tcp
sqlsrv.network_hostname_list: 0.0.0.0
sqlsrv.network_port_list: 5000
sqlsrv.application_type: USE_DEFAULT
sqlsrv.server_page_size: 16k
sqlsrv.force_buildmaster: no
sqlsrv.master_device_physical_name: /data/master.dat
sqlsrv.master_device_size: USE_DEFAULT
sqlsrv.master_database_size: USE_DEFAULT
sqlsrv.errorlog: USE_DEFAULT
sqlsrv.do_upgrade: no
sqlsrv.sybsystemprocs_device_physical_name: /data/sybsystemprocs.dat
sqlsrv.sybsystemprocs_device_size: USE_DEFAULT
sqlsrv.sybsystemprocs_database_size: USE_DEFAULT
sqlsrv.sybsystemdb_device_physical_name: /data/sybsystemdb.dat
sqlsrv.sybsystemdb_device_size: USE_DEFAULT
sqlsrv.sybsystemdb_database_size: USE_DEFAULT
sqlsrv.tempdb_device_physical_name: /data/tempdb.dat
sqlsrv.tempdb_device_size: USE_DEFAULT
sqlsrv.tempdb_database_size: USE_DEFAULT
sqlsrv.default_backup_server: ASE_BACKUP
# Additional param to dataserver cmd to skip some check that make server crash
# https://answers.sap.com/questions/13386863/i-updated-my-system-and-now-server-is-crahing.html 
sqlsrv.addl_cmdline_parameters: -T11889
sqlsrv.do_configure_pci: no
sqlsrv.sybpcidb_device_physical_name: PUT_THE_PATH_OF_YOUR_SYBPCIDB_DATA_DEVICE_HERE
sqlsrv.sybpcidb_device_size: USE_DEFAULT
sqlsrv.sybpcidb_database_size: USE_DEFAULT
# If sqlsrv.do_optimize_config is set to yes, both sqlsrv.avail_physical_memory and sqlsrv.avail_cpu_num need to be set.
sqlsrv.do_optimize_config: yes
sqlsrv.avail_physical_memory: 2048
sqlsrv.avail_cpu_num: 2
# Valid only if Remote Command and Control Agent for ASE is installed
sqlsrv.configure_remote_command_and_control_agent_ase: no
# Valid only if ASE Cockpit is installed.
# If set to yes, sqlsrv.technical_user and sqlsrv.technical_user_password are required.
sqlsrv.enable_ase_for_ase_cockpit_monitor: no
sqlsrv.technical_user:
sqlsrv.technical_user_password: