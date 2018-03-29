启动psql: pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log start
建立用户: /usr/local/Cellar/postgresql/9.5.5/bin/createuser -s postgres
登录: psql -U postgres -h localhost
重启: brew services restart postgresql

rm -rf /usr/local/var/postgres && initdb /usr/local/var/postgres -E utf8

zhuwenqian.com error fix
/etc/init.d/postgresql-9.2 start
/etc/init.d/httpd start

数据库导入导出
pg_dump -O -d wguild_development > dump.sql
pg_dump -c -O -d wguild_development > dump.sql
