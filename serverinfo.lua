{{/*Trigger : Regex `^-(server|guild)(-?info)?`*/}}

{{ $icon := "" }}
{{ $name := printf "%s" .Guild.Name }}
{{ if .Guild.Icon }}
	{{ $icon = printf "https://cdn.discordapp.com/icons/%d/%s.webp" .Guild.ID .Guild.Icon }}
{{ end }}
{{ $owner := userArg .Guild.OwnerID }}
{{ $levels := cslice
	"None: Unrestricted"
	"Faible : doit avoir un e-mail vérifié sur son compte Discord."
	"Moyen : doit également être membre de ce serveur pendant plus de 10 minutes."
	"(╯°□°）╯︵ ┻━┻ : Doit également être membre de ce serveur pendant plus de 10 minutes."
	"┻━┻ ﾐヽ(ಠ益ಠ)ノ彡┻━┻ : Doit avoir un téléphone vérifié sur leur compte Discord."
}}
{{ $afk := "n/a" }}
{{ if .Guild.AfkChannelID }}
	{{ $afk = printf "**Salon :**  <#%d> (%d)\n**Durée d'inactivité :** %s"
		.Guild.AfkChannelID
		.Guild.AfkChannelID
		(humanizeDurationSeconds (toDuration (mult .Guild.AfkTimeout .TimeSecond)))
	}}
{{ end }}
{{ $createdAt := div .Guild.ID 4194304 | add 1420070400000 | mult 1000000 | toDuration | (newDate 1970 1 1 0 0 0).Add }}
{{ $dec := randInt 0 16777216 }}
{{ $infoEmbed := cembed
	"author" (sdict "name" $name "icon_url" $icon)
    "color" $dec
	"thumbnail" (sdict "url" $icon)
	"fields" (cslice
		(sdict "name" "❯ Niveau de verification" "value" (index $levels .Guild.VerificationLevel))
		(sdict "name" "❯ Region" "value" .Guild.Region)
		(sdict "name" "❯ Membres" "value" (printf "**• Total:** %d Membress\n**• En ligne :** %d Membres" .Guild.MemberCount onlineCount))
		(sdict "name" "❯ Roles" "value" (printf "**• Total :** %d\nUtilise `#roles` pour voir tout les roles." (len .Guild.Roles)))
		(sdict "name" "❯ Owner" "value" (printf "%s" $owner.String))
		(sdict "name" "❯ AFK" "value" $afk)
	)
	"footer" (sdict "text" "Créer le")
	"timestamp" $createdAt
}}

{{ if .CmdArgs }}
	{{ if eq (index .CmdArgs 0) "icon" }}
		{{ sendMessage nil (cembed
			"author" (sdict "name" $name "icon_url" $icon)
			"title" "❯ Server Icon"
			"color" 13241535
			"image" (sdict "url" $icon)
		) }}
	{{ else }}
		{{ sendMessage nil $infoEmbed }}
	{{ end }}
{{ else }}
	{{ sendMessage nil $infoEmbed }}
{{ end }}