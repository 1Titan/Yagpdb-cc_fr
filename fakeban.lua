{{/*Trigger : Command `fakeban`*/}}

{{$prefix := index (reFindAllSubmatches `Prefix of \x60\d+\x60: \x60(.+)\x60` (exec "prefix")) 0 1}}
{{$args := parseArgs 1 (print $prefix "fakeban <Mention/ID> <Reason (optional)>")
	(carg "userid" "user")
	(carg "string" "reason")}}
{{$user := userArg ($args.Get 0)}}

{{if not ($args.Get 1)}}
	{{sendMessage nil (cembed
		"description" (print "🔨 **Banned " $user.Username "**#" $user.Discriminator " *(ID " $user.ID ")*" "\n📄**Reason:** Banned by Admin ([Logs](https://bit.ly/2ZhbSUj))")
		"color" 14043208
		"author" (sdict
			"name" (print .User.String " (ID " .User.ID ")")
			"icon_url" (.User.AvatarURL "4096"))
		"footer" (sdict
			"text" "Expires after: 420 weeks")
		"thumbnail" (sdict "url" ($user.AvatarURL "4096")))}}
	🔨 Banned `{{$user.String}}` for `8 years and 2 weeks`
	{{deleteTrigger 0}}
{{else}}
	{{sendMessage nil (cembed
		"description" (print "🔨 **Banned " $user.Username "**#" $user.Discriminator " *(ID " $user.ID ")*" "\n📄**Reason:** " ($args.Get 1) " ([Logs](https://bit.ly/2ZhbSUj))")
		"color" 14043208
		"author" (sdict
			"name" (print .User.String " (ID " .User.ID ")")
			"icon_url" (.User.AvatarURL "4096"))
		"footer" (sdict
			"text" "Expires after: 420 weeks")
		"thumbnail" (sdict "url" ($user.AvatarURL "4096")))}}
	🔨 Banned `{{$user.String}}` for `8 years and 2 weeks`
	{{deleteTrigger 0}}
{{end}}