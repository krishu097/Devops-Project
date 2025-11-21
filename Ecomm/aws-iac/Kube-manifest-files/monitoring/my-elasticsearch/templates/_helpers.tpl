{{- define "my-elasticsearch.name" -}}
{{ .Chart.Name }}
{{- end }}

{{- define "my-elasticsearch.fullname" -}}
{{ .Release.Name }}-{{ .Chart.Name }}
{{- end }}
