#!/usr/bin/env tarantool
local os = require('os')

box.cfg{
    listen = os.getenv("LISTEN"),
    replication         = "admin:test-cluster-cookie@" .. os.getenv("LISTEN"),
    replication_connect_timeout = 0.1,
    allocator = os.getenv("TEST_RUN_MEMTX_ALLOCATOR")
}

require('console').listen(os.getenv('ADMIN'))
