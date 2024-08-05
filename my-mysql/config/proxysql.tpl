datadir="/var/lib/proxysql"
admin_variables=
{
	refresh_interval="2000"
	cluster_proxysql_servers_save_to_disk="true"
	cluster_mysql_servers_diffs_before_sync="3"
	cluster_password="nb2wZpZ9OXXTF2Mv"
	mysql_ifaces="0.0.0.0:6032"
	cluster_check_status_frequency="100"
	cluster_mysql_users_diffs_before_sync="3"
	cluster_proxysql_servers_diffs_before_sync="3"
	admin_credentials="admin:admin;cluster:nb2wZpZ9OXXTF2Mv"
	admin-hash_passwords="true"
	cluster_check_interval_ms="200"
	cluster_mysql_servers_save_to_disk="true"
	cluster_mysql_users_save_to_disk="true"
	cluster_mysql_query_rules_diffs_before_sync="3"
	cluster_mysql_query_rules_save_to_disk="true"
	cluster_username="cluster"
}
mysql_variables=
{
	threads="4"
	monitor_password="proxysql"
	poll_timeout="2000"
	ssl_p2s_cert="/var/lib/certs/tls.crt"
	server_version="8.0.27"
	ssl_p2s_ca="/var/lib/certs/ca.crt"
	ssl_p2s_key="/var/lib/certs/tls.key"
	monitor_connect_interval="200000"
	monitor_username="proxysql"
	have_compress="true"
	monitor_galera_healthcheck_interval="2000"
	stacksize="1048576"
	ping_timeout_server="200"
	monitor_galera_healthcheck_timeout="800"
	max_connections="2048"
	monitor_ping_interval="200000"
	monitor_history="60000"
	commands_stats="true"
	default_query_delay="0"
	have_ssl="false"
	default_schema="information_schema"
	ping_interval_server_msec="10000"
	default_query_timeout="36000000"
	connect_timeout_server="10000"
	sessions_sort="true"
	interfaces="0.0.0.0:6033;/tmp/proxysql.sock"
}
mysql_users=
(
)
mysql_query_rules=
(
	{
		re_modifiers="CASELESS"
		flagIN=0
		apply=1
		rule_id=1
		destination_hostgroup=2
		match_digest="^SELECT.*FOR UPDATE$"
		negate_match_pattern=0
		active=1
	},
	{
		apply=1
		active=1
		re_modifiers="CASELESS"
		negate_match_pattern=0
		destination_hostgroup=3
		flagIN=0
		match_digest="^SELECT"
		rule_id=2
	},
	{
		re_modifiers="CASELESS"
		destination_hostgroup=2
		active=1
		rule_id=3
		match_digest=".*"
		apply=1
		negate_match_pattern=0
		flagIN=0
	}
)


{{- $ProxysqlServer := getEnvByName ( index $.podSpec.containers 0 ) "PROXYSQL_ENDPOINTS" }}
{{- $endpoints := splitList "," $ProxysqlServer -}}
proxysql_servers=
(
{{- range $i, $endpoint := $endpoints }}
    { hostname = "{{$endpoint}}", port = 6032, weight = 1 },
{{- end }}
)

{{- $BackEndServer := getEnvByName ( index $.podSpec.containers 0 ) "BACKEND_SERVER" -}}
{{- $servers := splitList "," $BackEndServer -}}
{{- $BackEndPort:= getEnvByName ( index $.podSpec.containers 0 ) "BACKEND_PORT" -}}
mysql_servers=
(
{{- $lastIndex := sub (len $servers) 1 }}
{{- range $i, $server := $servers }}
  {{- $hostgroup_id := 3 }}
  {{- if eq $i 0 -}}
    {{- $hostgroup_id = 2 }}
  {{- end -}}

  {{- if eq $i $lastIndex }}
  { hostgroup_id = {{$hostgroup_id}} , hostname = "{{$server}}", port = 3306, weight = 1, use_ssl = 0 }
  {{- else }}
  { hostgroup_id = {{$hostgroup_id}} , hostname = "{{$server}}", port = 3306, weight = 1, use_ssl = 0 },
  {{- end }}
{{- end }}
)