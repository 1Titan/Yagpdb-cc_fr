{{/*Trigger : Regex `^-(be|big-?emo(te|ji))`*/}}

{{ $dec := randInt 0 16777216 }}
{{ with reFindAllSubmatches `<(a)?:.*?:(\d+)>` .StrippedMsg }}
	{{ $animated := index . 0 1 }}
	{{ $id := index . 0 2 }}
	{{ $ext := ".png" }}
	{{ if $animated }} {{ $ext = ".gif" }} {{ end }}
	{{ $url := printf "https://cdn.discordapp.com/emojis/%s%s" $id $ext }}
	{{ sendMessage nil (cembed
		"title" "Big Emoji"
		"url" $url
		"color" $dec
		"image" (sdict "url" $url)
		"footer" (sdict "text" (joinStr "" "Emoji ID: " $id))
	) }}
{{ else }}
	Ce n'est pas un emoji valide. Réessayer.
{{ end }}