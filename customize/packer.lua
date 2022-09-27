local split = require("pl.utils").split
local pretty = require("pl.pretty").write
local strip = require("pl.stringx").strip
local lines = require("pl.stringx").splitlines
local _execex = require("pl.utils").executeex
local _exec = require("pl.utils").execute
local directories = require("pl.dir").getdirectories
local writefile = require("pl.utils").writefile
local readfile = require("pl.utils").readfile
local is_dir = require("pl.path").isdir
local is_file = require("pl.path").isfile

local CUSTOM_TEMPLATE="/custom_nginx.conf"

io.stdout:setvbuf("no")
io.stderr:setvbuf("no")


local function stderr(...)
  io.stderr:write(...)
  io.stderr:write("\n")
end


local function stdout(...)
  io.stdout:write(...)
  io.stdout:write("\n")
end


local function fail(msg)
  stderr(msg)
  os.exit(1)
end


local function header(msg)
  local fill1 = math.floor((80 - 2 - #msg)/2)
  local fill2 = 80 - 2 - #msg - fill1
  stdout(
    ("*"):rep(80).."\n"..
    "*"..(" "):rep(fill1)..msg..(" "):rep(fill2).."*\n"..
    ("*"):rep(80)
  )
end


local platforms = {
  {
    check = "apk -V",         -- check for alpine
    commands = {              -- run before anything else in build container
      "apk update",
      "apk add git",
      "apk add wget",
      "apk add zip",
      "apk add gcc",
      "apk add musl-dev",
    },
  }, {
    check = "yum --version",  -- check for rhel
    commands = {              -- run before anything else in build container
      "yum -y install git",
      "yum -y install unzip",
      "yum -y install zip",
      "yum -y install gcc gcc-c++ make",
    },
  }, {
    check = "stat /usr/bin/microdnf",  -- check for ubi-minimal
    commands = {                       -- run before anything else in build container
      "microdnf -y install git",
      "microdnf -y install unzip",
      "microdnf -y install zip",
      "microdnf -y install gcc gcc-c++ make",
    },
  }, {
    check = "apt -v",         -- check for Ubuntu
    commands = {              -- run before anything else in build container
      "apt update",
      "apt install -y zip",
      "apt install -y wget",
      "apt install -y build-essential",
    },
  },
}


local execex = function(cmd, ...)
  stdout("\027[32m", "[packer exec] ", cmd, "\027[0m")
  return _execex(cmd, ...)
end


local exec = function(cmd, ...)
  stdout("\027[32m", "[packer exec] ", cmd, "\027[0m")
  return _exec(cmd, ...)
end


local function prep_platform()
  for _, platform in ipairs(platforms) do
    local ok = exec(platform.check)
    if not ok then
      stdout(("platform test '%s' was negative"):format(platform.check))
    else
      stdout(("platform test '%s' was positive"):format(platform.check))
      for _, cmd in ipairs(platform.commands) do
        stdout(cmd)
        ok = exec(cmd)
        if not ok then
          fail(("failed executing '%s'"):format(cmd))
        end
      end
      return true
    end
  end
  stderr("WARNING: no platform match!")
end


local function is_empty_file(filename)
  local t = readfile(filename)
  if t then
    if t:gsub("\n", ""):gsub("\t", ""):gsub(" ","") == "" then
      return true
    end
  end
  return false
end


local function get_args()
  if not arg or
     not arg[1] or
     arg[1] == "--" and not arg[2] then
    -- no args, but maybe a custom config file?

    if is_empty_file(CUSTOM_TEMPLATE) then
      fail("no arguments to parse, commandline: " .. pretty(arg or {}))
    else
      stdout("no plugins specified, but a custom template exists")
      return
    end
  end

  local list = {}
  for i = 1, #arg do
    if arg[i] and arg[i] ~= "--" then
      local sp = split(arg[i], ",")
      for n = 1, #sp do
        local rock = strip(sp[n])
        if rock ~= "" then
          table.insert(list, rock)
        end
      end
    end
  end

  if #list == 0 then
    if is_empty_file(CUSTOM_TEMPLATE) then
      fail("no arguments to parse, commandline: " .. pretty(arg))
    else
      stdout("no plugins specified, but a custom template exists")
    end
  end

  stdout("rocks to install: " .. pretty(list))
  return list
end


local function get_plugins()
  local plugins = {}
  local cnt = 0

  for i = 1, 2 do
    local pattern, paths, extension
    if i == 1 then
      pattern = "%?%.lua$"
      extension = ".lua"
      paths = split(package.path, ";")
    else
      pattern = "%?%.so$"
      extension = ".so"
      paths = split(package.cpath, ";")
    end

    for _, path in ipairs(paths) do
      path = path:gsub(pattern, "kong/plugins/")
      if is_dir(path) then
        for _, dir in ipairs(directories(path)) do
          local plugin_name = dir:sub(#path + 1, -1)
          if is_file(dir .. "/handler" .. extension) then
            plugins[plugin_name] = true
            cnt = cnt + 1
          end
        end
      end
    end
  end

  stdout("Found ", cnt, " plugins installed")
  return plugins
end


local function get_rocks()
  local cmd = "luarocks list --tree=system --porcelain"
  local ok, _, sout, serr = execex(cmd)
  if not ok then
    fail(("failed to retrieve list of installed rocks: '%s' failed with\n%s\n%s"):format(
        cmd, sout, serr))
  end

  local rocks = {}
  local cnt = 0
  for _, rock in ipairs(lines(sout)) do
    cnt = cnt + 1
    local name, spec = rock:match("^(.-)\t(.-)\t")
    local rock_id = name.."-"..spec
    rocks[rock_id] = { name = name, spec = spec }
  end
  stdout("Found ", cnt, " rocks installed")
  return rocks
end


local function install_plugins(plugins, lr_flag)
  local cmd = "luarocks install --tree=system %s " .. lr_flag
  for _, rock in ipairs(plugins) do
    stdout(cmd:format(rock))

    local ok = exec(cmd:format(rock))
    if not ok then
      fail(("failed installing rock: '%s' failed"):format(cmd:format(rock)))
    end

    stdout("installed: "..rock)
    exec("luarocks show "..rock)
  end
end


local function check_custom_template()
  if is_empty_file(CUSTOM_TEMPLATE) then
    -- it's the empty_file, delete it
    os.remove(CUSTOM_TEMPLATE)
    stdout("No custom template found")
    return
  end
  stdout("Found a custom template")
end


local function start_rocks_server()
  if is_empty_file("/rocks-server") then
    stdout("No custom rocks found, using public luarocks.org as server")
    return ""
  end
  assert(exec("luarocks-admin make_manifest /rocks-server"))
  stdout("Local LuaRocks server manifest created")
  assert(exec("mkdir /nginx"))
  assert(exec("mkdir /nginx/logs"))
  assert(writefile("/nginx/nginx.conf", [[
events {
}

http {
    server {
        listen 127.0.0.1:8080;

        location / {
            root /rocks-server;
        }
    }
}
]]))
  assert(exec("touch /nginx/logs/error.log"))
  assert(exec("/usr/local/openresty/nginx/sbin/nginx " ..
              "-c /nginx/nginx.conf " ..
              "-p /nginx"))
  stdout("Nginx started as local LuaRocks server")
  stdout("List of locally available rocks:")
  assert(exec("luarocks search --all --porcelain --only-server=http://localhost:8080"))
  return " --only-server=http://localhost:8080 "
end


-- **********************************************************
-- Do the actual work
-- **********************************************************
header("Set up platform")
prep_platform()

header("Set up LuaRocks server")
local lr_flag = start_rocks_server()

header("Get arguments")
local rocks = get_args()


header("Get existing rocks")
local pre_installed_rocks = get_rocks()


header("Get existing plugin list")
local pre_installed_plugins = get_plugins()


header("Getting custom template")
check_custom_template()


header("Install the requested plugins")
install_plugins(rocks, lr_flag)


header("Get post-install plugin list and get the delta")
local plugins = {}
for plugin_name in pairs(get_plugins()) do
  if not pre_installed_plugins[plugin_name] then
    table.insert(plugins, plugin_name)
    stdout("added plugin: "..plugin_name)
  end
end
if not next(plugins) then
  stdout("No plugins were added")
end


header("Write new entry-point script")
assert(exec("mv /docker-entrypoint.sh /old-entrypoint.sh"))
local entrypoint = [=[
#!/bin/sh
set -e

if [ "$KONG_PLUGINS" = "" ]; then
  KONG_PLUGINS="bundled"
fi
# replace 'bundled' with the new set, including the custom ones
export KONG_PLUGINS=$(echo ",$KONG_PLUGINS," | sed "s/,bundled,/,bundled%s,/" | sed 's/^,//' | sed 's/,$//')

# prefix the custom template option, since the last one on the command line
# wins, so the user can still override this template
INITIAL="$1 $2"
if [ -f /custom_nginx.conf ]; then
  # only for these commands support "--nginx-conf"
  echo 1: $INITIAL
  if [ "$INITIAL" = "kong prepare" ] || \
     [ "$INITIAL" = "kong reload"  ] || \
     [ "$INITIAL" = "kong restart" ] || \
     [ "$INITIAL" = "kong start"   ] ; then
    INITIAL="$1 $2 --nginx-conf=/custom_nginx.conf"
  fi
fi
# shift 1 by 1; if there is only 1 arg, then "shift 2" fails
if [ ! "$1" = "" ]; then
  shift
fi
if [ ! "$1" = "" ]; then
  shift
fi

exec /old-entrypoint.sh $INITIAL "$@"
]=]
local plugin_list = "," .. table.concat(plugins, ",")
if plugin_list == "," then
  -- no plugins added
  plugin_list = ""
end
entrypoint = entrypoint:format(plugin_list)
assert(writefile("/docker-entrypoint.sh", entrypoint))
assert(exec("chmod +x /docker-entrypoint.sh"))
stdout(entrypoint)


header("Completed building plugins, rocks and/or template")

