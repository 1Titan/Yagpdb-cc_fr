{{/*Trigger : Command `mod`*/}}

{{$prefix := index (reFindAllSubmatches `Prefix of \x60\d+\x60: \x60(.+)\x60` (exec "prefix")) 0 1}}
{{$args := parseArgs 1 (print $prefix "mod <UserID/Mention>") (carg "userid" "User")}}
{{if reFind `\d+` .StrippedMsg}}
	{{$user := userArg ($args.Get 0)}}
	{{$userid := $args.Get 0}}
	{{$users := "Utilisateur inconnu"}}
	{{$usera := "https://cdn.discordapp.com/emojis/565142262401728512.png"}}
	{{if (userArg (index .CmdArgs 0))}}
		{{$userid = $user.ID}}
		{{$users = $user.String}}
		{{$usera = $user.AvatarURL "1024"}}
	{{end}}
	{{$x := sendMessageRetID nil (cembed
		"author" (sdict
			"name" (print $users " - Panneau Modération")
			"icon_url" $usera)
		"description" "<a:bongoban:636572687124398081> - Ban, 👢 - Kick, <:servermute:711553322225500201> - Mute, 🔊 - Unmute, ❌ - Fermer le menu")}}
	{{/*Permission Check*/}}
	{{$var1 := index (index (reFindAllSubmatches `.*\n\x60\d+\x60\n(.*)` (exec "viewperms")) 0) 1}}
	{{/*Ban*/}}
	{{if (reFind `BanMembers` $var1)}}
		{{addMessageReactions nil $x "a:bongoban:636572687124398081"}}
	{{end}}
	{{/*Kick*/}}
	{{if (reFind `KickMembers` $var1)}}
		{{if $user}}
			{{addMessageReactions nil $x "👢"}}
		{{end}}
	{{end}}
	{{/*Mute*/}}
	{{if (reFind `ManageRoles` $var1)}}
		{{if $user}}
			{{addMessageReactions nil $x "servermute:711553322225500201" "🔊"}}
		{{end}}
	{{end}}
	{{addMessageReactions nil $x "❌"}}
	{{$v1 := dbSetExpire .User.ID (print .CCID "-" (randInt 10000) "del_message") (print "del" $x "-" .Message.ID) 300}}
	{{$v2 := dbSetExpire .User.ID "mod_rq_message" (print "mod" $x "-" $userid) 300}}
	{{deleteMessage nil $x 300}}
	{{deleteTrigger 300}}
{{else}}This ID is invalid and doesn't exist!{{end}}