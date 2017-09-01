启动psql: pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log start
建立用户: /usr/local/Cellar/postgresql/9.5.5/bin/createuser -s postgres
登录: psql -U postgres -h localhost
重启: brew services restart postgresql
