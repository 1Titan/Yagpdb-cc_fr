{{/*Trigger : Regex `\A`*/}}

{{$color := 0}}{{$old := 0}}
{{range .Guild.Roles}}
    {{- if and (in $.Member.Roles .ID) (ne .Color 0) (gt .Position $old)}}
        {{- $old = .Position}}
        {{- $color = .Color}}
    {{- end}}
{{- end}}
{{if .Message.Content}}
{{$embed := cembed 
    "title" "Suggestion :ringed_planet:"
    "description" .Message.Content
    "color" $color
    "author" (sdict "name" .User.Username)
    "thumbnail" (sdict "url" (.User.AvatarURL "256"))
"footer" (sdict "text" "Marceau 🎯")
"timestamp" (currentTime) 
}}
{{ $mID := sendMessageRetID nil $embed}}
{{addMessageReactions nil $mID "Oui:779706462188077079" "Sign:779755224570789928" "Non:779755211437637632"}}
{{else}}
{{sendDM "Vous devez inclure un message !"}}
{{end}}
{{deleteTrigger}}