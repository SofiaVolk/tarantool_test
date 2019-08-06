#!/usr/bin/env tarantool

json = require('json')

ID = 1
HEADER = {['content-type'] = 'application/json'}

box.cfg {log='tarantool.txt'}
log = require('log')
log.info('START')

local tester = box.schema.space.create('kv', {if_not_exists = true})
tester:create_index('primary', {
    type = 'hash',
    parts = {ID, 'string'},
    if_not_exists = true
})


local function validate_body(body, key_in_body)
    if key_in_body then
        if type(body['key']) ~= "string" then
            return false
        end
    end
    if type(body['value']) ~= "table" then
        return false
    end
    return true
end


local function handle_get(self)
    local key = self:stash('id')
    local res = tester:select(key)
    if res[1] ~= nil then
        log.info('SELECT '..key..'')
        return {
            status = 200,
            headers = HEADER,
            body = json.encode(res[1])
        }
    end
    log.error('SELECT '..key..': no such key')
    return { status = 404 }
end


local function handle_delete(self)
    local key = self:stash('id')
    local res = tester:delete(key)
    if res ~= nil then
        log.info('DELETE '..key..'')
	    return { 
            status = 200,
            headers = HEADER,
            body = json.encode(res)
        }
    end
    log.error('DELETE '..key..': no such key')
    return { status = 404 }
end


local function handle_put(self)    
    local key = self:stash('id')
    json_from_request = self:json()
    if validate_body(json_from_request, false) then
        value = self:json()['value']
        local res = tester:select(key)
        --ER_TUPLE_FOUND (3)
        if res[1]~=nil then
            res = tester:replace({key, value})
            log.info('REPLACE '..key..'')
            return { 
                status = 200,
                headers = HEADER,
                body = json.encode(res)
            }
        end
        log.error('REPLACE '..key..': no such key')
        return { status = 404 }
    else
        log.error('REPLACE '..key..': invalid body format')
        return { status = 400 }
    end
end


local function handle_post(self)
    json_from_request = self:json()
    if validate_body(json_from_request, true) then
        key = self:json()['key']
        value = self:json()['value']
        
        --ER_TUPLE_FOUND (3)
        --res = tester:insert({key, value})
        --if box.error.last()==ER_TUPLE_FOUND then
            --log.error('INSERT'..key..': key already exists')
            --return { status = 409 }
        --end
        --log.info('INSERT'..key..'')
        --return { 
            --status = 200,
            --headers = HEADER,
            --body = json.encode(res)
        --}
        
        local res = tester:select(key)
        if res[1]~=nil then
             log.error('INSERT '..key..': key already exists')
             return { status = 409 }
        end
        res = tester:insert({key, value})
        log.info('INSERT '..key..'')
        return { 
            status = 200,
            headers = HEADER,
            body = json.encode(res)
        }
    else
        log.error('INSERT '..key..': invalid body format')
        return { status = 400 }
    end
end


local server = require('http.server').new('0.0.0.0', 8080)
server:route({ path = '/kv/:id', method = 'GET' }, handle_get)
server:route({ path = '/kv/:id', method = 'DELETE' }, handle_delete)
server:route({ path = '/kv/:id', method = 'PUT' }, handle_put)
server:route({ path = '/kv', method = 'POST' }, handle_post)
server:start()




