test_run = require 'test_run' .new()
netbox = require 'net.box'
fiber = require 'fiber'

 -- max increase in fiber.info entries count 
 -- after the test execution
ndelta = 5

nyields = 10
niters = 100
yield_sleepval = 0.001

pause_sleepval = 0.2 + 10 * nyields * yield_sleepval

done = 0
function yielder() \
    for i = 1,nyields do \
        fiber.sleep(yield_sleepval) \
    end done = done + 1 \
end

function fibcount() \
    local res = 0 \
    for _,v in pairs(fiber.info()) do \
        res = res + 1 \
    end \
    return res \
end

box.schema.user.grant('guest', 'execute', 'universe')
conn = netbox.connect(box.cfg.listen)

oldcnt = fibcount()

for i = 1,niters do \
    fiber.create(function() conn:call('yielder') end) \
end

fiber.sleep(pause_sleepval)
newcnt = fibcount()
newcnt

newcnt < oldcnt + ndelta

conn:close()
box.schema.user.revoke('guest', 'execute', 'universe')
