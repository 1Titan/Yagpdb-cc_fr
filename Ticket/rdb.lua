{{/*Trigger : Reaction `Added reaction only`*/}}

{{if eq .Reaction.Emoji.Name "✅"}}
{{dbDel .User.ID "ticket"}}
{{end}}