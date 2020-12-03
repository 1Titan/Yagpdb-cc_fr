{{/*Trigger : Regex `\A-r(eport)?u(ser)?(\s+|\z)`*/}}

{{$reportLog := 779402992972464140}} {{/*The channel where your reports are logged into.*/}}
{{$reportDiscussion := 779400645354192937}} {{/*Your channel where users talk to staff*/}}
{{$modRoles := cslice 779014497876312100}} {{/*RoleIDs of the roles which are considered moderator.*/}}
{{$adminRoles := cslice 779014497188839424}} {{/*RoleIDs of the roles which are considered admins. Can prime the database to setup the system and reset report count.*/}}

{{/*CONFIG AREA END*/}}


{{/*ACTUAL CODE*/}}
{{$isAdmin := false}}{{range .Member.Roles}}{{if in $adminRoles .}}{{$isAdmin = true}}{{end}}{{end}}
{{if (eq (len .CmdArgs) 1)}}
    {{if eq (index .CmdArgs 0) "dbSetup"}}
        {{if $isAdmin}}
                {{dbSet 2000 "reportLog" (toString $reportLog)}}
                {{dbSet 2000 "reportDiscussion" (toString $reportDiscussion)}}
                {{dbSet 2000 "modRoles" $modRoles}}
                {{dbSet 2000 "adminRoles" $adminRoles}}
                {{dbSet 2000 "ReportNo" 0}}
                {{sendMessage nil "**Base de données amorcée, réinitialisation du nombre de reports, le système est prêt à être utilisé !**"}}
        {{else}}
            {{sendMessage nil "Vous n'êtes pas autorisé à utiliser cette commande !"}}
        {{end}}
    {{end}}
{{else if not (ge (len .CmdArgs) 2)}}
    {{sendMessage nil (printf "```%s <User:Mention/ID> <Reason:Text>``` \n Pas assez d'arguments passés." .Cmd)}}
{{else}}
    {{$user := userArg (index .CmdArgs 0)}}
    {{if eq $user.ID .User.ID}}
        {{$silly := sendMessageRetID nil "Tu ne peux pas te signaler, idiot."}}
        {{deleteMessage nil $silly}}
    {{else}}
        {{$secret := adjective}}
        {{$logs250 := execAdmin "log" "250"}}
        {{$reason := joinStr " " (slice .CmdArgs 1)}}
        {{$reportGuide := (printf "\nIgnorer le report avec ❌, mettre sous enquête avec 🛡️, ou demandez plus d'informations générales avec ⚠️.")}}
        {{$userReportString := (printf  "<@%d> report <@%d> dans <#%d>." .User.ID $user.ID .Channel.ID)}}
        {{dbSet 2000 "reportGuideBasic" $reportGuide}}
        {{dbSet .User.ID "userReport" $userReportString}}
        {{$reportNo := dbIncr 2000 "ReportNo" 1}}
        {{$reportEmbed := cembed "title" (print "Report N°" $reportNo)
            "author" (sdict "name" (printf "%s (ID %d)" .User.String .User.ID) "icon_url" (.User.AvatarURL "256"))
            "thumbnail" (sdict "url" ($user.AvatarURL "512"))
            "description" $userReportString
            "fields" (cslice
                (sdict "name" "État actuel" "value" "__Non examiné encore.__")
                (sdict "name" "Raison du report" "value" $reason)
                (sdict "name" "Utilisateur report" "value" (printf "<@%d> (ID %d)" $user.ID $user.ID))
                (sdict "name" "Logs Message" "value" (printf "[dernier 250 messages](%s) \nTemps - `%s`" $logs250 (currentTime.Format "Mon 02 Jan 15:04:05")))
                (sdict "name" "Options du menu de réaction" "value" $reportGuide)
            )
            "footer" (sdict "text" "Pas encore de modérateur • Réclamer avec n'importe quelle réaction")
        }}
        {{$x := sendMessageRetID $reportLog $reportEmbed}}
        {{addMessageReactions $reportLog $x "❌" "🛡️" "⚠️"}}
        {{$response := sendMessageRetID nil "Utilisateur report aux autorités compétentes !"}}
        {{dbSet .User.ID "key" $secret}}
        {{dbSet $x "reportAuthor" (toString .User.Mention)}}
        {{deleteMessage nil $response}}
        {{sendDM (printf "L'utilisateur a signalé aux autorités compétentes ! Si vous souhaitez annuler votre report, tapez simplement `-cancelr %d %s` dans <#779400645354192937>.\n **Une raison est requise.**" $x $secret)}}
    {{end}}
{{end}}