{{/*Trigger : Regex `\A-(my|start|stop|set|get|del)b(irth)?days?`*/}}

{{$mods := cslice 779014497188839424}}
{{$channelID := 779423606199025676}} {{/* Channel ID to send the bday msgs */}}
{{$bdayMsg := "Félicitations pour ton anniversaire !"}}
{{$invertedOrder := false}}
{{$kickUnderAge := false}}
{{$banUnderAge := true}}
{{/* End */}}

{{/* DONT TOUCH */}}
{{/* Vars */}}
{{$isMod := false}}{{$map := ""}}{{$error := ""}}{{$day := 0}}{{$month := 0}}{{$year := 0}}{{$isUnderAge := false}}{{$isValidDate := false}}{{$user := .User}}{{$checkDate := ""}}{{$insideMap := sdict}}{{$list := cslice}}{{$out := ""}}{{$send := false}}{{$userMonth := ""}}{{$today := sdict}}{{$delay := 86400}}
{{$commonError := "La syntaxe de date correcte est : `dd/mm/yyyy` - Exemple : `20/12/1998`"}}
{{$commonErrorInverted := "La syntaxe de date correcte est : `mm/dd/yyyy` - Exemple : `12/20/1998`"}}
{{$synt := "Usage correct : -getbday @user"}}

{{/* Checks */}}
{{range .Member.Roles}} {{if in $mods .}} {{$isMod = true}} {{end}} {{end}}
{{if not .ExecData}}
	{{if reFind `(?i)(my|set)` .Cmd}}
		{{with .CmdArgs}}
			{{$map = split (index . 0) "/"}}
			{{if and (eq (len .) 2) $isMod}} {{with index . 1 | userArg}} {{$user = .}} {{else}} {{$error = "Invalid User."}} {{end}} {{end}}
		{{end}}
		{{with $map}}
			{{if eq (len .) 3}} {{$counter := 0}}
				{{$year := index . 2 | toInt}}
				{{if $invertedOrder}} {{$day = index . 1 | toInt}} {{$month = index . 0 | toInt}}
				{{else}} {{$day = index . 0 | toInt}} {{$month = index . 1 | toInt}}
				{{end}}
				{{with $day}} {{if or (gt . 31) (lt . 1)}} {{$error = print $error "\nJour invalide."}} {{else}} {{$counter = add $counter 1}} {{end}} {{end}}
				{{with $month}} {{if or (gt . 12) (lt . 1)}} {{$error = print $error "\nMois invalide."}} {{else}} {{$counter = add $counter 1}} {{end}} {{end}}
				{{if not $year}} {{$error = print $error "\nAnnée invalide."}} {{else}} {{$counter = add $counter 1}} {{end}}
				{{$checkDate = newDate $year $month $day 0 0 0}}
				{{if and (eq $counter 3) (eq (printf "%d" $checkDate.Month) (str $month)) (eq (printf "%d" $checkDate.Day) (str $day)) (eq (printf "%d" $checkDate.Year) (str $year))}} {{$counter = add $counter 1}}
				{{else if (or (not $error) (eq $error "Utilisateur invalide."))}} {{$error = print $error "\nDate invalide (généralement le 31e jour sur un mois de 30 jours ou le 29 février dans une année non bissextile)"}}
				{{end}}
				{{if eq $counter 4}} {{$isValidDate = true}}
					{{if lt ((currentTime.Sub $checkDate).Hours | toInt) 113880}} {{$isUnderAge = true}} {{end}}
				{{end}}
			{{else}}
				{{if $invertedOrder}} {{$error = $commonErrorInverted}}
				{{else}} {{$error = $commonError}}
				{{end}}
			{{end}}
		{{else}}
			{{if $invertedOrder}} {{$error = $commonErrorInverted}}
			{{else}} {{$error = $commonError}}
			{{end}}
		{{end}}
	{{end}}
{{end}}
{{if $isValidDate}}
	{{$userMonth = printf "%d" $checkDate.Month | toInt}}
	{{with (dbGet $userMonth "bdays").Value}}
		{{$insideMap = sdict .}}
	{{end}}
{{end}}

{{/* Work */}}
{{if and $isUnderAge $kickUnderAge (not $banUnderAge) (not $isMod)}} {{execAdmin "kick" $user "Nous n'autorisons pas les utilisateurs de moins de 13 ans sur ce serveur."}} {{end}}
{{if and $isUnderAge $banUnderAge (not $isMod)}} {{execAdmin "ban" $user "Nous n'autorisons pas les utilisateurs de moins de 13 ans sur ce serveur."}} {{end}}
{{with .ExecData}}
	{{if eq (printf "%T" .) "int64"}} {{scheduleUniqueCC $.CCID $channelID . "bdays" true}} {{end}}
	{{dbDel (currentTime.Add (mult -24 $.TimeHour | toDuration)).Day "bdayannounced"}}
	{{with (dbGet (printf "%d" currentTime.Month | toInt) "bdays").Value}} {{$today = sdict .}} {{end}}
	{{range (index $today (str currentTime.Day))}}
		{{if getMember .}}
			{{$bdayMsg = print $bdayMsg "\n<@" . ">"}}
			{{$send = true}}
		{{end}}
	{{end}}
	{{if and $send (not (dbGet currentTime.Day "bdayannounced"))}} {{dbSet currentTime.Day "bdayannounced" true}} {{sendMessageNoEscape nil $bdayMsg}} {{end}}
{{else}}
	{{if $isMod}}
		{{if and (reFind `(?i)set` .Cmd) $isValidDate (not $error)}}
			{{if eq (len .CmdArgs) 2}}
				{{with $insideMap}}
					{{with index . (str $checkDate.Day)}} {{$list = $list.AppendSlice .}} {{end}}
					{{if not (in $list $user.ID)}}
						{{$list = $list.Append $user.ID}}
						{{.Set (str $checkDate.Day) $list}}
						{{dbSet $userMonth "bdays" $insideMap}}
					{{end}}
				{{else}}
					{{$list = $list.Append $user.ID}}
					{{$insideMap.Set (str $checkDate.Day) $list}}
					{{dbSet $userMonth "bdays" $insideMap}}
				{{end}}
				{{with (dbGet $user.ID "bday").Value}}
					{{if ne (print .) (print $checkDate)}}
						{{$listIn := cslice}}
						{{$thisDay := str .Day}} {{$thisMonth := printf "%d" .Month | toInt}}
						{{with sdict (dbGet (printf "%d" .Month | toInt) "bdays").Value}}
							{{$needMap := .}}
							{{range index . $thisDay}}
								{{if ne . $user.ID}}
									{{$listIn = $list.Append .}}
								{{end}}
							{{end}}
							{{$needMap.Set $thisDay $listIn}}
							{{dbSet $thisMonth "bdays" $needMap}}
						{{end}}
					{{else}}
						{{$error = print "C'est déjà " $user.Mention "'s birthday."}}
					{{end}}
				{{end}}
				{{if not $error}}
					{{dbSet $user.ID "bday" $checkDate}}
					{{if $invertedOrder}} {{$out = print "Le bday de " $user.Mention " devait être " ($checkDate.Format "01/02/2006")}}
					{{else}} {{$out = print "Le bday de " $user.Mention " devait être " ($checkDate.Format "02/01/2006")}}
					{{end}}
				{{end}}
			{{else}}
				{{if $invertedOrder}} {{$error = "Pas assez d'arguments passés.\nUne utilisation correcte est : `-set 12/20/1998 @user`"}}
				{{else}} {{$error = "Pas assez d'arguments passés.\nUne utilisation correcte est : `-set 20/12/1998 @user`"}}
				{{end}}
			{{end}}
		{{else if reFind `(?i)stop` .Cmd}}
			{{cancelScheduledUniqueCC .CCID "bdays"}}
			{{$out = "Je ne féliciterai plus les gens pour leur anniversaire."}}
		{{else if reFind `start` .Cmd}}
			{{with .CmdArgs}} {{with index . 0 | toDuration}} {{$delay = add $delay .Seconds}} {{end}} {{end}}
			{{if or (ne (currentTime.Add (mult 1000000000 $delay | toDuration)).Day ((currentTime.Add (mult 24 .TimeHour | toDuration)).Day)) (ge $delay 172800)}} {{$error = "Délai trop long pour commencer à envoyer des messages d'anniversaire. Vous ne pouvez définir des retards que jusqu'à demain à 00:00 UTC"}}
			{{else}}
				{{execCC .CCID $channelID 1 $delay}}
				{{$out = print "Tout est prêt ! Chaque jour à **" ((currentTime.Add (mult 1000000000 $delay | toDuration)).Format "15:04 UTC") "** Je féliciterai les utilisateurs si c'est leur anniversaire."}}
			{{end}}
		{{else if reFind `(?i)get` .Cmd}}
			{{with .CmdArgs}}
				{{with index . 0 | userArg}}
					{{$user = .}}
					{{with (dbGet .ID "bday").Value}}
						{{if $invertedOrder}} {{$out = print "Le bday de " $user.Mention " est " (.UTC.Format "01/02/2006")}}
						{{else}} {{$out = print "Le bday de " $user.Mention " est " (.UTC.Format "02/01/2006")}}
						{{end}}
					{{else}}
						{{$error = "Cet utilisateur n'a pas set son bday."}}
					{{end}}
				{{else}}
					{{$error = $synt}}
				{{end}}
			{{else}}
				{{$error = $synt}}
			{{end}}
		{{end}}
	{{end}}
	{{if and (reFind `(?i)my` .Cmd) $isValidDate (not $out) (or (and (or $kickUnderAge $banUnderAge) (not $isUnderAge)) (and (not $kickUnderAge) (not $banUnderAge)))}}
		{{if not (dbGet .User.ID "bday")}}
			{{with $insideMap}}
				{{with index . (str $checkDate.Day)}} {{$list = $list.AppendSlice .}}  {{end}}
				{{if not (in $list $user.ID)}}
					{{$list = $list.Append $user.ID}}
					{{.Set (str $checkDate.Day) $list}}
					{{dbSet $userMonth "bdays" $insideMap}}
				{{end}}
			{{else}}
				{{$list = $list.Append $user.ID}}
				{{$insideMap.Set (str $checkDate.Day) $list}}
				{{dbSet $userMonth "bdays" $insideMap}}
			{{end}}
			{{dbSet .User.ID "bday" $checkDate}}
			{{if $invertedOrder}} {{$out = print "Votre anniversaire devait être " ($checkDate.Format "01/02/2006")}}
			{{else}} {{$out = print "Votre anniversaire devait être " ($checkDate.Format "02/01/2006")}}
			{{end}}
		{{else}}
			{{$error = "Votre anniversaire devait être."}}
		{{end}}
	{{end}}
	{{if and (reFind `(?i)del` .Cmd)}}
		{{$user := .User}} {{with .CmdArgs}} {{with index . 0 | userArg}} {{if $isMod}} {{$user = .}} {{end}} {{else}} {{$error = print $error "\nInvalid user."}} {{end}} {{end}}
		{{with (dbGet $user.ID "bday").Value}}
			{{dbDel $user.ID "bday"}}
			{{$listIn := cslice}}
			{{$thisDay := str .Day}} {{$thisMonth := printf "%d" .Month | toInt}}
			{{with sdict (dbGet (printf "%d" .Month | toInt) "bdays").Value}}
				{{$needMap := .}}
				{{range index . $thisDay}}
					{{if ne . $user.ID}}
						{{$listIn = $list.Append .}}
					{{end}}
				{{end}}
				{{$needMap.Set $thisDay $listIn}}
				{{dbSet $thisMonth "bdays" $needMap}}
			{{end}}
			{{$out = print "Suppression réussie de l'anniversaire de " $user.String}}
		{{else}}
			{{$error = print $user.String "n'a pas de set son anniversaire."}}
		{{end}}
	{{end}}
{{end}}

{{/* Outs */}}
{{with $error}} {{.}} {{end}}
{{with $out}} {{.}} {{end}}