{{/*Trigger : Regex `\A`*/}}

{{$color := 0}}{{$old := 0}}
{{range .Guild.Roles}}
{{ $dec := randInt 0 16777216 }}
{{- end}}
{{if .Message.Content}}
{{$embed := cembed 
    "title" "Confession anonyme 🤫"
    "description" .Message.Content
    "color" $color
"footer" (sdict "text" "Marceau 🎯")
"timestamp" (currentTime) 
}}
{{ $mID := sendMessageRetID nil $embed}}
{{else}}
{{sendDM "Vous devez inclure un message !"}}
{{end}}
{{deleteTrigger}}