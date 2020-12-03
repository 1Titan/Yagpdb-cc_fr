{{sleep 3}}
{{$tn := reFind `\d+` .Channel.Name}}
{{editChannelName .Channel.ID (print "ticket-" $tn)}}
{{$setup := sdict}} {{with (dbGet 0 "ticket_cfg").Value}} {{$setup = sdict .}} {{end}}
{{$CloseEmoji := $setup.CloseEmoji}}
{{$SolveEmoji := $setup.SolveEmoji}}
{{$AdminOnlyEmoji := $setup.AdminOnlyEmoji}}
{{$ConfirmCloseEmoji := $setup.ConfirmCloseEmoji}}
{{$CancelCloseEmoji := $setup.CancelCloseEmoji}}
{{$ModeratorRoleID := toInt $setup.MentionRoleID}}
{{$SchedueledCCID := toInt $setup.SchedueledCCID}}
{{$masterChannel := toInt $setup.masterTicketChannelID}}
{{$displayMSGID := toInt $setup.displayMSGID}}
{{$Delay := toInt $setup.Delay}}
{{$TO := $setup.ticketOpen}}
{{$TS := $setup.ticketClose}}
{{$TC := $setup.ticketSolving}}
{{$time :=  currentTime}}
{{$content := print "Bonjour, " .User.Mention "\nNouveau ticket ouvert, <@&" $ModeratorRoleID "> !!"}}
{{ $dec := randInt 0 16777216 }}
{{$descr := print "Les <@&" $ModeratorRoleID "> sont à ton service !\n\nPour l'instant, veuillez décrire ci dessous votre préoccupation / problème afin que nous puissions répondre plus rapidement!\n\nPour ajouter / retirer quelqu'un sur le ticket faites `$add/remove id`\n\nUn système d'emoji est disponible. Le " $SolveEmoji " pour aider au ticket. Le " $AdminOnlyEmoji " pour mettre le ticket uniquement pour les admins\n\nPour fermer le ticket, cliquez sur " $CloseEmoji ". Clique sur " $ConfirmCloseEmoji " pour confirmer " $CancelCloseEmoji " pour annuler."}}
{{$embed := cembed "color" 8190976 "description" $descr "timestamp" $time "author" (sdict "name" (joinStr "" "Ticket de " .User.Username " 🎟️") "url" "https://probot.io/dashboard"  "icon_url" "https://cdn.discordapp.com/attachments/756278982164349068/779702600638791680/Marceau.png") "color" ($dec) "thumbnail" (sdict "url" (.User.AvatarURL "256"))
`footer` (sdict "text" "Marceau 🎯")
}}
{{$id := sendMessageNoEscapeRetID nil (complexMessage "content" $content "embed" $embed)}}
{{addMessageReactions nil $id $CloseEmoji $SolveEmoji $AdminOnlyEmoji}}
{{$realDelay := mult $Delay 3600}}
{{$AoD := 1}}
{{if gt $Delay 3}} {{$AoD = 2}} {{end}}
{{if eq $AoD 1}}
    {{scheduleUniqueCC $SchedueledCCID nil $realDelay $tn (sdict "alert" 2)}}
    {{dbSet (toInt $tn) "ticket" (sdict "channelID" .Channel.ID "AoD" $AoD "Delay" (str $Delay) "pos" 1 "ticketID" $tn "userID" (str .User.ID) "mainMsgID" (str $id) "ticketCounter" (str 0) "duration" ($time.Add (toDuration (print $Delay "h30m"))) "ctime" $time "alert" 2 "creator" (userArg .User.ID))}}
{{else}}
    {{$3HoursAlert := sub $realDelay 10800}}
    {{scheduleUniqueCC $SchedueledCCID nil $3HoursAlert $tn (sdict "alert" 1)}}
    {{dbSet (toInt $tn) "ticket" (sdict "channelID" .Channel.ID "AoD" $AoD "Delay" (str $Delay) "pos" 1 "ticketID" $tn "userID" (str .User.ID) "mainMsgID" (str $id) "ticketCounter" (str 0) "duration" ($time.Add (toDuration (print $Delay "h"))) "ctime" $time "alert" 1 "creator" (userArg .User.ID))}}
{{end}}
{{with (dbGet 0 "ticketDisplay").Value}}
    {{$map := sdict .}}
    {{if lt (len .) 50}}
        {{$map.Set (str $.Channel.ID) $TO}}
    {{else}}
        {{$pos := 0}}
        {{range $k, $v := .}}
            {{- if eq $pos 0}} {{$pos = toInt $k}} {{end -}}
            {{- if lt (toInt $k) $pos}} {{$pos = toInt $k}} {{end -}}
        {{end}}
        {{$map.Del $pos}}
        {{$map.Set (str $.Channel.ID) $TO}}
    {{end}}
    {{dbSet 0 "ticketDisplay" $map}}
{{else}}
    {{dbSet 0 "ticketDisplay" (sdict (str $.Channel.ID) $TO)}}
{{end}}
{{$arr := cslice}}
{{with (dbGet 0 "ticketDisplay").Value}}
    {{$map := sdict .}}
    {{range $k, $v := $map}} {{- $arr = $arr.Append (cslice $v $k) -}} {{end}}
    {{$len := len $arr}}
    {{range seq 0 $len}}
        {{- $min := . -}}
        {{- range seq (add . 1) $len -}}
            {{- if gt (index $arr $min 1) (index $arr . 1) }} {{ $min = . }} {{ end -}}
        {{- end -}}
        {{- if ne $min . -}}
            {{- $ := index $arr . -}}
            {{- $arr.Set . (index $arr $min) -}}
            {{- $arr.Set $min $ -}}
        {{- end -}}
    {{end}}
{{end}}
{{$desc := printf "%s - %-10s\n" "**TicketID**" "**Status**"}}
{{range $arr}} {{- $desc = print $desc (printf (print "<#%d> - `%-" (index . 0 | len) "s`\n") (index . 1 | toInt) (index . 0)) -}} {{end}}
{{editMessage $masterChannel $displayMSGID (cembed "title" "Tickets Display" "color" (randInt 16777216) "description" $desc)}}

{{if (dbGet .User.ID "ticket")}}
{{sendDM (joinStr "" "Vous avez déjà un ticket actif sur le serveur !")}}
{{exec "ticket close" "Ticket en double"}}
{{else}}
{{dbSet .User.ID "ticket" .Channel.ID}}
{{end}}