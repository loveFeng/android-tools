#! /bin/bash
name="/data/dbbackup/mysql/smart_server/`date +%Y%m%d%H%M`.sql.gz"
mysqldump --user=root --password='111' --databases smart_server | gzip -9 > $name

#/data/envar/tools/upBaiduYun.sh $name
