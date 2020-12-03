{{/*Trigger : Reaction `added only`*/}}

{{/*Validation steps*/}}
{{$reportLog := (dbGet 2000 "reportLog").Value|toInt64}}
{{$reportDiscussion := (dbGet 2000 "reportDiscussion").Value|toInt64}}
{{if eq .Reaction.ChannelID $reportLog}}
{{/*Set some vars, cutting down on DB stuff, Readability shit*/}}
{{$reportGuide := ((dbGet 2000 "reportGuideBasic").Value|str)}}{{$user := userArg (dbGet .Reaction.MessageID "reportAuthor").Value}}{{$userReportString := ((dbGet 2000 (printf "userReport%d" $user.ID)).Value|str)}}
{{$userCancelString := ((dbGet 2000 (printf "userCancel%d" $user.ID)).Value|str)}}{{$mod := (printf "\nModérateur responsable : <@%d>" .Reaction.UserID)}}{{$modRoles := (cslice).AppendSlice (dbGet 2000 "modRoles").Value}}
{{$isMod := false}} {{range .Member.Roles}} {{if in $modRoles .}} {{$isMod = true}}{{end}}{{end}}
{{with .Message.Embeds}}{{$report := index . 0|structToSdict}}{{range $k, $v := $report}}{{if eq (kindOf $v true) "struct"}}{{$report.Set $k (structToSdict $v)}}{{end}}{{end}}
{{if $isMod}}
    {{$report.Set "Footer" (sdict "text" (print "Modérateur responsable : " $.User.String) "icon_url" ($.User.AvatarURL "256"))}}
    {{$report.Set "Author" (sdict "text" (print $user.String "(ID" $user.ID ")") "icon_url" ($user.AvatarURL "256"))}}
    {{if (dbGet $.Reaction.MessageID "ModeratorID")}}
        {{if eq $.User.ID (toInt64 (dbGet $.Reaction.MessageID "ModeratorID").Value)}}
            {{if eq $.Reaction.Emoji.Name "❌"}}{{/*Dismissal*/}}
                {{sendMessage $reportDiscussion (printf "<@%d>: Votre report a été rejeté. %s" $user.ID $mod)}}
                {{deleteAllMessageReactions nil $.Reaction.MessageID}}
                {{$report.Set "Fields" ((cslice).AppendSlice $report.Fields)}}{{$report.Fields.Set 0 (sdict "name" "État actuel" "value" "__Report rejeté.__")}}
                {{$report.Set "Fields" ((cslice).AppendSlice $report.Fields)}}{{$report.Fields.Set 4 (sdict "name" "Options du menu de réaction" "value" "Warn pour `Faux report` avec ❗ ou terminer sans warn avec 👌.")}}
                {{$report.Set "color" 65280}}
                {{editMessage nil $.Reaction.MessageID (complexMessageEdit "embed" $report)}}
                {{addReactions "❗" "👌"}}
                {{dbSet $user.ID "key" "used"}}
            {{else if eq $.Reaction.Emoji.Name "🛡️"}}{{/*Taking care*/}}
                {{sendMessage $reportDiscussion (printf "<@%d>: Votre report est pris en charge ; Si vous avez des informations complémentaires, veuillez le poster ci-dessous. %s" $user.ID $mod)}}
                {{deleteAllMessageReactions nil $.Reaction.MessageID}}
                {{$report.Set "Fields" ((cslice).AppendSlice $report.Fields)}}{{$report.Fields.Set 0 (sdict "name" "État actuel" "value" "__Sous enquête.__")}}
                {{$report.Set "Fields" ((cslice).AppendSlice $report.Fields)}}{{$report.Fields.Set 4 (sdict "name" "Options du menu de réaction" "value" "Ignorer avec ❌ ou résoudre avec 👍.")}}
                {{$report.Set "color" 16776960}}
                {{editMessage nil $.Reaction.MessageID (complexMessageEdit "embed" $report)}}
                {{addReactions "❌" "👍"}}
                {{dbSet $user.ID "key" "used"}}
            {{else if eq $.Reaction.Emoji.Name "⚠️"}}{{/*Request info*/}}
                {{if ne (dbGet $user.ID "key").Value "used"}}{{/*Without cancellation request*/}}
                    {{sendMessage $reportDiscussion (printf "<@%d>: Plus d'informations ont été demandées. Veuillez les poster ci-dessous. %s" $user.ID $mod)}}
                    {{deleteAllMessageReactions nil $.Reaction.MessageID}}
                    {{$report.Set "Fields" ((cslice).AppendSlice $report.Fields)}}{{$report.Fields.Set 0 (sdict "name" "État actuel" "value" "__Plus d'informations demandées.__")}}
                    {{$report.Set "Fields" ((cslice).AppendSlice $report.Fields)}}{{$report.Fields.Set 4 (sdict "name" "Options du menu de réaction" "value" "Ignorer avec ❌ ou lancez une enquête avec 🛡️.")}}
                    {{$report.Set "color" 255}}
                    {{editMessage nil $.Reaction.MessageID (complexMessageEdit "embed" $report)}}
                    {{addReactions "❌" "🛡️"}}
                {{else}} 
                    {{/*With Cancellation request*/}}
                    {{sendMessage $reportDiscussion (printf "<@%d>: Plus d'informations concernant votre annulation ont été demandées. Veuillez les poster ci-dessous. %s" $user.ID $mod)}}
                    {{deleteAllMessageReactions nil $.Reaction.MessageID}}
                    {{$report.Set "Fields" ((cslice).AppendSlice $report.Fields)}}{{$report.Fields.Set 0 (sdict "name" "État actuel" "value" "__Plus d'informations demandées.__")}}
                    {{$report.Set "Fields" ((cslice).AppendSlice $report.Fields)}}{{$report.Fields.Set 4 (sdict "name" "Options du menu de réaction" "value" "Ignorer la demande avec 🚫, ou accepter la demande __(et annuler le report)__ avec ✅")}}
                    {{$report.Set "color" 255}}
                    {{editMessage nil $.Reaction.MessageID (complexMessageEdit "embed" $report)}}
                    {{addReactions "🚫" "✅"}}
                {{end}}
            {{else if eq $.Reaction.Emoji.Name "🚫"}}{{/*Dismissal of cancellation*/}}
                {{sendMessage $reportDiscussion (printf "<@%d>: Votre demande d'annulation a été rejetée. %s" $user.ID $mod)}}
                {{deleteAllMessageReactions nil $.Reaction.MessageID}}
                {{$report.Set "Fields" ((cslice).AppendSlice $report.Fields)}}{{$report.Fields.Set 0 (sdict "name" "État actuel" "value" "__Demande d'annulation refusée.__")}}
                {{$report.Set "Fields" ((cslice).AppendSlice $report.Fields)}}{{$report.Fields.Set 4 (sdict "name" "Options du menu de réaction" "value" $reportGuide)}}
                {{$report.Set "color" 16711680}}
                {{editMessage nil $.Reaction.MessageID (complexMessageEdit "embed" $report)}}
                {{addReactions "❌" "🛡️" "⚠️"}}
            {{else if eq $.Reaction.Emoji.Name "✅"}}{{/*Cancellation approved*/}}
                {{sendMessage $reportDiscussion (printf "<@%d>: Votre demande d'annulation a été acceptée. %s" $user.ID $mod)}}
                {{deleteAllMessageReactions nil $.Reaction.MessageID}}
                {{$report.Set "Fields" ((cslice).AppendSlice $report.Fields)}}{{$report.Fields.Set 0 (sdict "name" "État actuel" "value" "__Demande d'annulation acceptée, report annulé.__")}}
                {{$report.Set "Fields" ((cslice).AppendSlice (slice $report.Fields 0 4))}}
                {{$report.Set "color" 65280}}
                {{editMessage nil $.Reaction.MessageID (complexMessageEdit "embed" $report)}}
                {{dbDel $.Reaction.MessageID "ModeratorID"}}
                {{addReactions "🏳️"}}
            {{else if eq $.Reaction.Emoji.Name "👍"}}{{/*Report resolved*/}}
                {{sendMessage $reportDiscussion (printf "<@%d>: Votre report a été résolu. %s" $user.ID $mod)}}
                {{deleteAllMessageReactions nil $.Reaction.MessageID}}
                {{$report.Set "Fields" ((cslice).AppendSlice $report.Fields)}}{{$report.Fields.Set 0 (sdict "name" "État actuel" "value" "__Report résolu.__")}}
                {{$report.Set "Fields" ((cslice).AppendSlice (slice $report.Fields 0 4))}}
                {{$report.Set "color" 65280}}
                {{editMessage nil $.Reaction.MessageID (complexMessageEdit "embed" $report)}}
                {{dbDel $.Reaction.MessageID "ModeratorID"}}
                {{addReactions "🏳️"}}
            {{else if eq $.Reaction.Emoji.Name "❗"}}
                {{$silent := exec "warn" $user.ID "False Report."}}
                {{deleteAllMessageReactions nil $.Reaction.MessageID}}
                {{$report.Set "Fields" ((cslice).AppendSlice $report.Fields)}}{{$report.Fields.Set 0 (sdict "name" "État actuel" "value" "__Report rejeté, averti pour faux report.__")}}
                {{$report.Set "Fields" ((cslice).AppendSlice (slice $report.Fields 0 4))}}
                {{$report.Set "color" 65280}}
                {{editMessage nil $.Reaction.MessageID (complexMessageEdit "embed" $report)}}
                {{dbDel $.Reaction.MessageID "ModeratorID"}}
                {{addReactions "🏳️"}}
            {{else if eq $.Reaction.Emoji.Name "👌"}}
                {{deleteAllMessageReactions nil $.Reaction.MessageID}}
                {{$report.Set "Fields" ((cslice).AppendSlice $report.Fields)}}{{$report.Fields.Set 0 (sdict "name" "État actuel" "value" "__Report rejeté, aucune autre mesure prise.__")}}
                {{$report.Set "Fields" ((cslice).AppendSlice (slice $report.Fields 0 4))}}
                {{$report.Set "color" 65280}}
                {{editMessage nil $.Reaction.MessageID (complexMessageEdit "embed" $report)}}
                {{dbDel $.Reaction.MessageID "ModeratorID"}}
                {{addReactions "🏳️"}}
            {{end}}
        {{else}}
            {{deleteMessageReaction nil $.Reaction.MessageID $.User.ID "❌" "❗" "👌" "👍" "✅" "🛡️" "⚠️" "🚫"}}
        {{end}}
    {{else}}
        {{if ne $.Reaction.Emoji.Name "🏳️"}}
        {{dbSet $.Reaction.MessageID "ModeratorID" (toString $.User.ID)}}
        {{deleteMessageReaction nil $.Reaction.MessageID $.User.ID "❌" "❗" "👌" "👍" "✅" "🛡️" "⚠️" "🚫"}}
        {{$tempMessage := sendMessageRetID nil (printf "<@%d>: Aucun modérateur détecté, vous avez réclamé ce report maintenant. Vos réactions ont été réinitialisées, veuillez recommencer. Merci ;)" $.User.ID)}}
        {{deleteMessage nil $tempMessage 5}}
        {{$report.Set "Footer" (sdict "text" (print "Modérateur responsable : " $.User.String) "icon_url" ($.User.AvatarURL "256"))}}
        {{editMessage nil $.Reaction.MessageID (complexMessageEdit "embed" $report)}}{{end}}
    {{end}}
{{else}}
{{deleteMessageReaction nil $.Reaction.MessageID $.User.ID "❌" "❗" "👌" "👍" "✅" "🛡️" "⚠️" "🚫"}}
{{end}}{{end}}{{else}}{{end}}