{{/*Trigger : Contains `re`*/}}

{{$setup := sdict}} {{with (dbGet 0 "ticket_cfg").Value}} {{$setup = sdict .}} {{end}}
{{$category := toInt $setup.category}}
{{$admins := $setup.Admins}}
{{$mods := $setup.Mods}}
{{$CloseEmoji := $setup.CloseEmoji}}
{{$SolveEmoji := $setup.SolveEmoji}}
{{$AdminOnlyEmoji := $setup.AdminOnlyEmoji}}
{{$ConfirmCloseEmoji := $setup.ConfirmCloseEmoji}}
{{$CancelCloseEmoji := $setup.CancelCloseEmoji}}
{{$ModeratorRoleID := toInt $setup.MentionRoleID}}
{{$time :=  currentTime}}
{{$tn := reFind `\d+` .Channel.Name}}
{{if $tn}}
    {{$master := sdict (dbGet (toInt $tn) "ticket").Value}}
    {{$isMod := false}}
    {{/* END OF VARIABLES */}}

    {{/* CHECKS */}}
    {{range .Member.Roles}} {{if (or (in $mods .) (in $admins .))}} {{$isMod = true}} {{end}} {{end}}

    {{if and $isMod (eq .Channel.ParentID $category) (ne $master.pos 3)}}
        {{deleteMessage nil (toInt $master.mainMsgID) 2}}
        {{$autor := $master.creator}}
        {{$content := print "Bonjour, " .User.Mention "\nNouveau ticket ouvert, <@&" $ModeratorRoleID "> !!"}}
        {{ $dec := randInt 0 16777216 }}
        {{$descr := print "Les <@&" $ModeratorRoleID "> sont à ton service !\n\nPour l'instant, veuillez décrire ci dessous votre préoccupation / problème afin que nous puissions répondre plus rapidement!\n\nPour ajouter / retirer quelqu'un sur le ticket faites `$add/remove id`\n\nUn système d'emoji est disponible. Le " $SolveEmoji " icône pour aider au ticket. Le " $AdminOnlyEmoji " pour mettre le ticket uniquement pour les admins\n\nPour fermer le ticket, cliquez sur " $CloseEmoji ". Clique sur " $ConfirmCloseEmoji " icône pour confirmer " $CancelCloseEmoji " icône pour annuler."}}
        {{$embed := cembed "color" 8190976 "description" $descr "timestamp" $time "author" (sdict "name" (joinStr "" "Ticket de " .User.Username " 🎟️") "url" "https://probot.io/dashboard"  "icon_url" "https://cdn.discordapp.com/attachments/756278982164349068/779702600638791680/Marceau.png") "color" ($dec) "thumbnail" (sdict "url" (.User.AvatarURL "256"))
        `footer` (sdict "text" "Marceau 🎯")
        }}
        {{$id := sendMessageNoEscapeRetID nil (complexMessage "content" $content "embed" $embed)}}
        {{addMessageReactions nil $id $CloseEmoji $SolveEmoji $AdminOnlyEmoji}}
        {{$master.Set "mainMsgID" (str $id)}}
        {{dbSet (toInt $tn) "ticket" $master}}
        {{deleteTrigger 2}}
    {{end}}
{{end}}