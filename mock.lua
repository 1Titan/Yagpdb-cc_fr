{{/*Trigger : Command `mock`*/}}

{{ with .StrippedMsg }}
{{ $out := "" }}
{{- range $k, $v := split (lower .) "" -}}
  {{ if mod $k 2 }} {{ $out = joinStr "" $out (upper $v) }}
  {{ else }} {{ $out = joinStr "" $out $v }} {{ end }}
{{- end -}}
{{ $dec := randInt 0 16777216 }}
{{ sendMessage nil (cembed
  "description" $out
  "thumbnail" (sdict "url" "https://cdn.discordapp.com/emojis/316315555453730817.png?v=1")
  "color" $dec
) }}
{{ else }}
Veuillez me fournir un texte pour que je me mock.
{{ end }}