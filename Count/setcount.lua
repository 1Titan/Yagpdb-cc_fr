{{/*Trigger : Command `setcount`*/}}

{{if .CmdArgs}}
{{if toInt (index .CmdArgs 0)}}
{{dbSet 118 "counter_count" (index .CmdArgs 0)}}fixed :)
{{end}}
{{else}}
Tu veux vraiment mettre une valeur?
{{end}}