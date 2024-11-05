#!/bin/bash
/usr/bin/pg_dump --dbname=postgresql://tuser:PassW0rdStr0ng@localhost:5432/test_db | gzip > /home/vagrant/backups/db/test_db_backup_$(date "+%Y-%m-%d-%H-%M-%S").sql.gz