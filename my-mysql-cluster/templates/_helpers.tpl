{{/*
Define the cluster name.
We truncate at 15 chars because KubeBlocks will concatenate the names of other resources with cluster name
*/}}
{{- define "mysql.clusterName" }}
{{- $name := .Release.Name }}
{{- if not (regexMatch "^[a-z]([-a-z0-9]*[a-z0-9])?$" $name) }}
{{ fail (printf "Release name %q is invalid. It must match the regex %q." $name "^[a-z]([-a-z0-9]*[a-z0-9])?$") }}
{{- end }}
{{- if gt (len $name) 16 }}
{{ fail (printf "Release name %q is invalid, must be no more than 15 characters" $name) }}
{{- end }}
{{- $name }}
{{- end }}

{{/*
Define cluster labels
*/}}
{{- define "mysql.clusterLabels" -}}
helm.sh/chart: {{ include "mysql.chart" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/instance: {{ include "mysql.clusterName" . }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "mysql.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}


{{/*
Define component resources, including cpu, memory
*/}}
{{- define "mysql.componentResources" }}
{{- $requestCPU := (float64 .Values.server.cpu) }}
{{- $requestMemory := (float64 .Values.server.memory) }}
{{- if .Values.server.requests }}
{{- if and .Values.server.requests.cpu (lt (float64 .Values.server.requests.cpu) $requestCPU) }}
{{- $requestCPU = .Values.server.requests.cpu }}
{{- end }}
{{- if and .Values.server.requests.memory (lt (float64 .Values.server.requests.memory) $requestMemory) }}
{{- $requestMemory = .Values.server.requests.memory }}
{{- end }}
{{- end }}
resources:
  limits:
    cpu: {{ .Values.server.cpu | quote }}
    memory: {{ print .Values.server.memory "Gi" | quote }}
  requests:
    cpu: {{ $requestCPU | quote }}
    memory: {{ print $requestMemory "Gi" | quote }}
{{- end }}

{{/*
Define component storages, including volumeClaimTemplates
*/}}
{{- define "mysql.componentStorages" }}
volumeClaimTemplates:
  - name: data # ref clusterDefinition components.containers.volumeMounts.name
    spec:
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: {{ print .Values.server.storage "Gi" }}
      {{- if .Values.server.storageClassName }}
      storageClassName: {{ .Values.server.storageClassName | quote }}
      {{- end }}
{{- end }}


{{/*
Define component resources, including cpu, memory
*/}}
{{- define "proxysql.componentResources" }}
{{- $requestCPU := (float64 .Values.proxysql.cpu) }}
{{- $requestMemory := (float64 .Values.proxysql.memory) }}
{{- if .Values.proxysql.requests }}
{{- if and .Values.proxysql.requests.cpu (lt (float64 .Values.proxysql.requests.cpu) $requestCPU) }}
{{- $requestCPU = .Values.proxysql.requests.cpu }}
{{- end }}
{{- if and .Values.proxysql.requests.memory (lt (float64 .Values.proxysql.requests.memory) $requestMemory) }}
{{- $requestMemory = .Values.proxysql.requests.memory }}
{{- end }}
{{- end }}
resources:
  limits:
    cpu: {{ .Values.proxysql.cpu | quote }}
    memory: {{ print .Values.proxysql.memory "Gi" | quote }}
  requests:
    cpu: {{ $requestCPU | quote }}
    memory: {{ print $requestMemory "Gi" | quote }}
{{- end }}

{{/*
Define component storages, including volumeClaimTemplates
*/}}
{{- define "proxysql.componentStorages" }}
volumeClaimTemplates:
  - name: data # ref clusterDefinition components.containers.volumeMounts.name
    spec:
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: {{ print .Values.proxysql.storage "Gi" }}
      {{- if .Values.proxysql.storageClassName }}
      storageClassName: {{ .Values.proxysql.storageClassName | quote }}
      {{- end }}
{{- end }}

