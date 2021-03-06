#!bin/lua
local os, string, arg, next, tostring, collectgarbage =
  os, string, arg, next, tostring, collectgarbage
local version = require"cfg-core.strings".version
local std = require"cfg-core.std"
local args = require"cfg-core.args"
local cli = require"cfg-core.cli"
local lib = require"lib"
local fmt, time, fd = lib.fmt, lib.time, lib.fd
local unistd = require"posix.unistd"
local signal = require"posix.signal"
local sysstat = require"posix.sys.stat"
local syslog = require"posix.syslog"
local systime = require"posix.sys.time"
local inotify = require"inotify"
local inspect = require"inspect"
local t1
_ENV = nil

while true do
  local handle, wd
  local source, hsource, runenv, opts = cli.opt(arg, version)
  if args["d"] then
    fmt.print("%s\n", "main")
    fmt.print("%s\n", inspect.inspect(source))
    fmt.print("%s\n", "handlers")
    fmt.print("%s\n", inspect.inspect(hsource))
    break
  end
  ::RUN::
  t1 = systime.gettimeofday()
  local R, M = cli.try(source, hsource, runenv)
  if not R.failed and not R.repaired then
    R.kept = true
  end
  if opts.debug then
    fmt.print("------------\n")
    if R.kept then
      fmt.print("Kept: %s\n", R.kept)
    elseif R.repaired then
      fmt.print("Repaired: %s\n", R.repaired)
    elseif R.failed then
      fmt.print("Failed: %s\n", R.failed)
      fmt.panic("Failed!\n")
    end
    local t2 = time.diff(systime.gettimeofday(), t1)
    t2 = string.format("%s.%s", tostring(t2.sec), tostring(t2.usec))
    if t2 == 0 or t2 == 1.0 then
      fmt.print("Finished run in %.f second\n", 1.0)
    else
      fmt.print("Finished run in %.f seconds\n", t2)
    end
  else
    if R.failed then
      os.exit(1)
    end
  end
  if opts.watch then
    if unistd.geteuid() == 0 then
      if sysstat.stat("/proc/self/oom_score_adj") then
        fd.write("/proc/self/oom_score_adj", "-1000")
      else
        fd.write("/proc/self/oom_adj", "-1000")
      end
    end
    handle = inotify.init()
    wd = handle:addwatch(opts.script, inotify.IN_MODIFY, inotify.IN_ATTRIB)
    local bail = function(sig)
      handle:rmwatch(wd)
      handle:close()
      std.log(opts.syslog, opts.log,
        string.format("Caught signal %s. Exiting.", tostring(sig)), syslog.LOG_ERR)
      os.exit(255)
    end
    signal.signal(signal.SIGINT, bail)
    signal.signal(signal.SIGTERM, bail)
    handle:read()
    collectgarbage()
  elseif opts.periodic then
    unistd.sleep(opts.periodic)
    collectgarbage()
    goto RUN
  else
    break
  end
end

