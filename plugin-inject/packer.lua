local split = require("pl.utils").split
local pretty = require("pl.pretty").write
local strip = require("pl.stringx").strip
local lines = require("pl.stringx").splitlines
local execex = require("pl.utils").executeex
local exec = require("pl.utils").execute
local files = require("pl.dir").getfiles
local directories = require("pl.dir").getdirectories
local writefile = require("pl.utils").writefile
local is_dir = require("pl.path").isdir
local is_file = require("pl.path").isfile


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
    check = "apk -V",     -- check for alpine
    commands = {          -- run once before anything else
      "apk update",
      "apk add git",
      "apk add zip",
    },
  },
}

local function prep_platform()
  for _, platform in ipairs(platforms) do
    local ok = exec(platform.check)
    if not ok then
      stdout(("platform test '%s' was negative"):format(platform.check))
    else
      stdout(("platform test '%s' was positive"):format(platform.check))
      for _, cmd in ipairs(platform.commands) do
        stdout(cmd)
        local ok = exec(cmd)
        if not ok then
          fail(("failed executing '%s'"):format(cmd))
        end
      end
      return
    end
  end
  stderr("WARNING: no platform match!")
end


local get_args = function()
  if not arg or
     not arg[1] or
     arg[1] == "--" and not arg[2] then
    fail("no arguments to parse, commandline: " .. pretty(arg or {}))
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
    fail("no arguments to parse, commandline: " .. pretty(arg))
  end

  stdout("rocks to install: " .. pretty(list))
  return list
end


local function get_plugins()
  local plugins = {}

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
          end
        end
      end
    end
  end

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
  for _, rock in ipairs(lines(sout)) do
    local name, spec = rock:match("^(.-)\t(.-)\t")
    local rock_id = name.."-"..spec
    rocks[rock_id] = { name = name, spec = spec }
  end
  return rocks
end


local function install_plugins(plugins)
  local cmd = "luarocks install --tree=system %s"
  for _, rock in ipairs(plugins) do
    stdout(cmd:format(rock))

    local ok = exec(cmd:format(rock))
    if not ok then
      fail(("failed installing rock: '%s' failed"):format(cmd:format(rock)))
    end

    stdout("installed: "..rock)
  end
end


local function pack_rocks(rocks)
  local cmd = "cd /plugins && luarocks pack %s %s"
  for _, rock in pairs(rocks) do
    stdout(cmd:format(rock.name, rock.spec))

    local ok = exec(cmd:format(rock.name, rock.spec))
    if not ok then
      fail(("failed packing rock: '%s-%s' failed"):format(rock.name, rock.spec))
    end

    stdout("packed: "..rock.name.."-"..rock.spec)
  end
end


-- **********************************************************
-- Do the actual work
-- **********************************************************
header("Set up platform")
prep_platform()


header("Get arguments")
local rocks = get_args()


header("Get existing rocks")
local pre_installed_rocks = get_rocks()


header("Get existing plugin list")
local pre_installed_plugins = get_plugins()


header("Install the requested plugins")
install_plugins(rocks)


header("Get post-install rocks list and get the delta")
local added_rocks
do
  local post_installed_rocks = get_rocks()
  for k in pairs(pre_installed_rocks) do
    if post_installed_rocks[k] then
      post_installed_rocks[k] = nil  -- remove the ones we already had
    end
  end
  added_rocks = post_installed_rocks
end
if not next(added_rocks) then
  fail("no additional rocks were added")
end
for k in pairs(added_rocks) do
  stdout("added rock: "..k)
end


header("Get post-install plugin list and get the delta")
local plugins = {}
for plugin_name in pairs(get_plugins()) do
  if not pre_installed_plugins[plugin_name] then
    table.insert(plugins, plugin_name)
    stdout("added plugin: "..plugin_name)
  end
end


header("Pack newly installed rocks")
assert(exec("mkdir /plugins"))
pack_rocks(added_rocks)


header("Write install script")
local script = [=[
#!/bin/sh

# replace the entry point
mv /docker-entrypoint.sh /old-entrypoint.sh
cat <<'EOF' >> /docker-entrypoint.sh
#!/bin/sh
set -e

if [[ "$KONG_PLUGINS" == "" ]]; then
  if [[ "$KONG_CUSTOM_PLUGINS" == "" ]]; then
    export KONG_CUSTOM_PLUGINS="%s"
    export KONG_PLUGINS="bundled,$KONG_CUSTOM_PLUGINS"
  fi
fi

exec /old-entrypoint.sh "$@"
EOF
chmod +x /docker-entrypoint.sh

# install the rocks
%s

# clean up by deleting all the temporary stuff
rm -rf /plugins
]=]
local t = {}
local cmd = "luarocks install --deps-mode=none %s && rm %s"
for _, filename in ipairs(files("/plugins/"), "*.rock") do
  table.insert(t, cmd:format(filename, filename))
end
script = script:format(
  table.concat(plugins, ","),
  table.concat(t, "\n")
)
assert(writefile("/plugins/install_plugins.sh", script))
assert(exec("chmod +x /plugins/install_plugins.sh"))
stdout(script)


header("Completed")

