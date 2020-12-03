{{/*Trigger : Command `choose`*/}}

{{ if .CmdArgs }}
{{ .User.Mention }}, Je choisis **{{ index .CmdArgs (randInt (len .CmdArgs)) }}**!
{{ else }}
Veuillez me fournir quelques articles à choisir: par exemple, `-choose "Dormir" "Sport" `.
{{ end }}