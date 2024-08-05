{{/*
Define mysql component definition name
*/}}
{{- define "mysql.componentDefName" -}}
{{- if eq (len .Values.compDefinitionVersionSuffix) 0 -}}
my-mysql
{{- else -}}
{{- printf "mysql-%s" .Values.compDefinitionVersionSuffix -}}
{{- end -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "mysql.labels" -}}
helm.sh/chart: {{ include "mysql.chart" . }}
{{ include "mysql.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "mysql.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "mysql.selectorLabels" -}}
app.kubernetes.io/name: {{ include "mysql.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Expand the name of the chart.
*/}}
{{- define "mysql.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Define mysql component definition name
*/}}
{{- define "proxysql.componentDefName" -}}
{{- if eq (len .Values.compDefinitionVersionSuffix) 0 -}}
my-proxysql
{{- else -}}
{{- printf "mysql-%s" .Values.compDefinitionVersionSuffix -}}
{{- end -}}
{{- end -}}
