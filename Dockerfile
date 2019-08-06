FROM tarantool/tarantool:1

COPY api.lua /opt/tarantool

WORKDIR /work
RUN chmod -R 777 /work

CMD ["tarantool", "/opt/tarantool/api.lua"]
