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
helm.sh/chart: {{ include "kblib.chart" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/instance: {{ include "kblib.clusterName" . }}
{{- end }}

{{/*
Define component resources, including cpu, memory
*/}}
{{- define "mysql.componentResources" }}
{{- $requestCPU := (float64 .Values.cpu) }}
{{- $requestMemory := (float64 .Values.memory) }}
{{- if .Values.requests }}
{{- if and .Values.requests.cpu (lt (float64 .Values.requests.cpu) $requestCPU) }}
{{- $requestCPU = .Values.requests.cpu }}
{{- end }}
{{- if and .Values.requests.memory (lt (float64 .Values.requests.memory) $requestMemory) }}
{{- $requestMemory = .Values.requests.memory }}
{{- end }}
{{- end }}
resources:
  limits:
    cpu: {{ .Values.cpu | quote }}
    memory: {{ print .Values.memory "Gi" | quote }}
  requests:
    cpu: {{ $requestCPU | quote }}
    memory: {{ print $requestMemory "Gi" | quote }}
{{- end }}

{{/*
Define component storages, including volumeClaimTemplates
*/}}
{{- define "kblib.componentStorages" }}
volumeClaimTemplates:
  - name: data # ref clusterDefinition components.containers.volumeMounts.name
    spec:
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: {{ print .Values.storage "Gi" }}
      {{- if .Values.storageClassName }}
      storageClassName: {{ .Values.storageClassName | quote }}
      {{- end }}
{{- end }}
