{{/*Trigger : Regex `^-(user|member)(-?info)?`*/}}

{{ $member := .Member }}
{{ $user := .User }}
{{ $args := parseArgs 0 "**Syntax:** `-userinfo [user]`" (carg "member" "target") }}
{{ if $args.IsSet 0 }}
	{{ $member = $args.Get 0 }}
	{{ $user = $member.User }}
{{ end }}

{{ $roles := "" }}
{{- range $k, $v := $member.Roles -}}
	{{ if eq $k 0 }} {{ $roles = printf "<@&%d>" . }}
	{{ else }} {{ $roles = printf "%s, <@&%d>" $roles . }} {{ end }}
{{- end -}}
{{ $bot := "Non" }}
{{ if $user.Bot }} {{ $bot = "Oui" }} {{ end }}
{{ $createdAt := div $user.ID 4194304 | add 1420070400000 | mult 1000000 | toDuration | (newDate 1970 1 1 0 0 0).Add }}
{{ $dec := randInt 0 16777216 }}
{{ sendMessage nil (cembed
	"author" (sdict "name" (printf "%s (%d)" $user.String $user.ID) "icon_url" ($user.AvatarURL "256"))
	"fields" (cslice
		(sdict "name" "❯ Pseudo" "value" (or $member.Nick "*None set*"))
		(sdict "name" "❯ Rejoint le" "value" ($member.JoinedAt.Parse.Format "Jan 02, 2006 3:04 AM"))
		(sdict "name" "❯ Créer le" "value" ($createdAt.Format "Monday, January 2, 2006 at 3:04 AM"))
		(sdict "name" (printf "❯ Rôles (%d Total)" (len $member.Roles)) "value" (or $roles "n/a"))
		(sdict "name" "❯ Bot" "value" $bot)
	)
	"color" $dec
	"thumbnail" (sdict "url" ($user.AvatarURL "256"))
) }}