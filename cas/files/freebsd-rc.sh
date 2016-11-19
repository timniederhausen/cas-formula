#! /bin/sh

# cas {{ service_name }}
# Maintainer: @tim
# Authors: @tim

# PROVIDE: {{ service_name }}
# REQUIRE: LOGIN
# KEYWORD: shutdown

. /etc/rc.subr

name="{{ service_name }}"
rcvar="{{ service_name }}_enable"

load_rc_config {{ service_name }}
: ${{ '{' }}{{ service_name }}_enable:="NO"}

required_dirs="{{ directory }}"

# daemon
cas_user="{{ user }}"
cas_pidfile="/var/run/${name}.pid"
cas_options="--spring.cloud.config.server.native.searchLocations={{ directory }} --logging.config=file:{{ directory }}/log4j2.xml"
command=/usr/sbin/daemon
command_args="-c -p ${cas_pidfile} java -jar {{ war }} ${cas_options} > /var/log/cas/cas-console.log 2>&1"
start_precmd="cas_precmd"

cas_precmd()
{
    install -o ${cas_user} /dev/null ${cas_pidfile}
}

PATH="${PATH}:/usr/local/bin"
run_rc_command "$1"
