{{/*Trigger : Regex `^-(avatar|av|pfp)`*/}}

{{ $user := .User }}
{{ $args := parseArgs 0 "**Syntax:** `-avatar [user]`" (carg "userid" "user") }}
{{ if $args.IsSet 0 }}
	{{ $user = userArg ($args.Get 0) }}
{{ end }}
{{ $dec := randInt 0 16777216 }}
{{ sendMessage nil (cembed
	"author" (sdict "name" (printf "%s" $user.String) "icon_url" ($user.AvatarURL "256"))
	"title" "❯ Avatar"
	"image" (sdict "url" ($user.AvatarURL "2048"))
	"color" $dec
) }}