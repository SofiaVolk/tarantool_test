FROM tarantool/tarantool:1

COPY api.lua /opt/tarantool

WORKDIR /home/

CMD ["tarantool", "/opt/tarantool/api.lua"]
