#!/bin/sh
set -Eeo pipefail

# usage: file_env VAR [DEFAULT]
#    ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
# "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
file_env() {
  var="$1"
  fileVar="${var}_FILE"
  def="${2:-}"
  # Do not continue if _FILE env is not set
  eval "fileVarValue=\${${fileVar}}"
  if [ -z "$fileVarValue" ]; then
    return
  fi
  eval "varValue=\${${var}}"
  if [ -n "$varValue" ] && [ -n "$fileVarValue" ]; then
    echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
    exit 1
  fi
  val="$def"
  if [ -n "$varValue" ]; then
    val="$varValue"
  elif [ -n "$fileVarValue" ]; then
    val="$(cat "$fileVarValue")"
  fi
  export "$var"="$val"
  unset "$fileVar"
}

export KONG_NGINX_DAEMON=${KONG_NGINX_DAEMON:-off}

if [ "$1" = "kong" ]; then

  all_kong_options="/usr/local/share/lua/5.1/kong/templates/kong_defaults.lua"
  set +Eeo pipefail
  while IFS='' read -r LINE || [ -n "$LINE" ]; do
      opt=$(echo "$LINE" | grep "=" | sed "s/=.*$//" | sed "s/ //" | tr '[:lower:]' '[:upper:]')
      file_env "KONG_$opt"
  done < "$all_kong_options"
  set -Eeo pipefail

  file_env KONG_PASSWORD
  PREFIX=${KONG_PREFIX:-/usr/local/kong}

  if [ "$2" = "docker-start" ]; then
    kong prepare -p "$PREFIX" "$@"

    ln -sf /dev/stdout "$PREFIX/logs/access.log"
    ln -sf /dev/stdout "$PREFIX/logs/admin_access.log"
    ln -sf /dev/stderr "$PREFIX/logs/error.log"

    exec /usr/local/openresty/nginx/sbin/nginx \
      -p "$PREFIX" \
      -c nginx.conf
  fi
fi

exec "$@"
