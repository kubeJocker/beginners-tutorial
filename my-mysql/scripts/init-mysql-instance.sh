#!/bin/sh
set -ex

# logging functions
mysql_log() {
	local type="$1"; shift
	# accept argument string or stdin
	local text="$*"; if [ "$#" -eq 0 ]; then text="$(cat)"; fi
	local dt; dt="$(date --rfc-3339=seconds)"
	printf '%s [%s] [Entrypoint]: %s\n' "$dt" "$type" "$text"
}
mysql_note() {
	mysql_log Note "$@"
}
mysql_warn() {
	mysql_log Warn "$@" >&2
}
mysql_error() {
	mysql_log ERROR "$@" >&2
	exit 1
}

mysql_port="3306"

# wait for mysql to be available
wait_for_connectivity() {
  local timeout=600
  local start_time=$(date +%s)
  local current_time

  while true; do
    current_time=$(date +%s)
    if [ $((current_time - start_time)) -gt $timeout ]; then
      exit 1
    fi

    # Send PING and check for mysql response
    if  mysqladmin -P 3306 -u "$MYSQL_ROOT_USER" -p"$MYSQL_ROOT_PASSWORD" PING | grep -q "mysqld is alive"; then
      mysql_note "mysql is reachable."
      break
    fi

    sleep 5
  done
}

setup_master_slave() {

  mysql -P 3306 -u $MYSQL_ROOT_USER -p$MYSQL_ROOT_PASSWORD -e "STOP SLAVE;RESET MASTER;RESET SLAVE ALL;";

  mysql_note "setup_master_slave"
  master_host_name=$(echo "${KB_CLUSTER_COMP_NAME}_MYSQL_0_SERVICE_HOST" | tr '-' '_' | tr '[:lower:]' '[:upper:]')
  master_host=${!master_host_name}

  last_digit=${KB_POD_NAME##*-}
  self_service_name=$(echo "${KB_CLUSTER_COMP_NAME}_MYSQL_${last_digit}" | tr '_' '-' | tr '[:upper:]' '[:lower:]' )
  host_name=$(echo "${self_service_name}_SERVICE_HOST" | tr '-' '_'  | tr '[:lower:]' '[:upper:]'  )

  # If the master_host is empty, then this pod is the first one in the cluster, init cluster info database and create user.
  if [[ $master_from_orc == "" && $last_digit -eq 0 ]]; then
    mysql_note "This is Master Pod"
  else
    mysql_note "Wait for master to be ready"
    change_master "$master_host"
  fi
  return 0
}

change_master() {
  mysql_note "Change master"
  master_host=$1
  master_port=3306

  username=$mysql_username
  password=$mysql_password

  mysql -u "$MYSQL_ROOT_USER" -p"$MYSQL_ROOT_PASSWORD" << EOF
SET GLOBAL READ_ONLY=1;
STOP SLAVE;
CHANGE MASTER TO
MASTER_AUTO_POSITION=1,
MASTER_CONNECT_RETRY=1,
MASTER_RETRY_COUNT=86400,
MASTER_HOST='$master_host',
MASTER_PORT=$master_port,
MASTER_USER='$MYSQL_ROOT_USER',
MASTER_PASSWORD='$MYSQL_ROOT_PASSWORD';
START SLAVE;
EOF
  mysql_note "CHANGE MASTER successful for $master_host."

}

main() {
  wait_for_connectivity
  setup_master_slave
  echo "init mysql instance for orc completed"
}

main
