{{/*Trigger : Reaction `added only`*/}}


{{if not (ge (len .CmdArgs) 3)}}
    ```{{.Cmd}} <Message:ID> <Key:Text> <Reason:Text>```
    Pas assez d'arguments passés.
{{else}}
    {{$reportLog := (dbGet 2000 "reportLog").Value|toInt64}}
    {{$reportDiscussion := (dbGet 2000 "reportDiscussion").Value|toInt64}}
    {{$userKey := (dbGet .User.ID "key").Value|str}}
    {{$reportMessageID := ((index .CmdArgs 0)|toInt64)}}
    {{if eq (toInt64 (dbGet $reportMessageID "reportAuthor").Value) (toInt64 .User.ID)}}
            {{if eq "used" $userKey}}
                {{$response := sendMessageRetID nil "Votre dernier report a déjà été annulé !"}}
                {{deleteMessage nil $response}}
            {{else}}
            {{if eq (index .CmdArgs 1|str) $userKey}}
                {{if ge (len .CmdArgs) 3}}
                    {{$reason := joinStr " " (slice .CmdArgs 2)}}
                    {{$userReportString := (dbGet 2000 (printf "userReport%d" .User.ID)).Value|str}}
                    {{$cancelGuide := (printf "Refuser la demande avec 🚫, accepter avec ✅, ou demandez plus d'informations avec ⚠️.")}}
                    {{dbSet 2000 "cancelGuideBasic" $cancelGuide}}
                    {{$userCancelString := (printf "L'annulation de ce report a été demandée. \n Raison : `%s`" $reason)}}
                    {{$combinedString := (print $userReportString " \n " $userCancelString)}}
                    {{dbSet 2000 (printf "userCancel%d" .User.ID) $userCancelString}}
                    {{$report := index (getMessage $reportLog $reportMessageID).Embeds 0|structToSdict}}
                    {{range $k, $v := $report}}
                        {{if eq (kindOf $v true) "struct"}}
                            {{$report.Set $k (structToSdict $v)}}
                        {{end}}
                    {{end}}
                    {{$user := userArg (dbGet $reportMessageID "reportAuthor").Value}}
                    {{with $report}}
                        {{.Author.Set "Icon_URL" $report.Author.IconURL}} 
                        {{.Footer.Set "Icon_URL" $report.Footer.IconURL}}
                        {{.Set "description" $combinedString}}
                        {{.Set "color" 16711935}}
                        {{$.Set "Author" (sdict "text" (print $user.String "(ID" $user.ID ")") "icon_url" ($user.AvatarURL "256"))}}
                        {{.Set "Fields" ((cslice).AppendSlice .Fields)}}{{.Fields.Set 4 (sdict "name" "Options du menu de réaction" "value" $cancelGuide)}}
                    {{end}}
                    {{editMessage $reportLog $reportMessageID (complexMessageEdit "embed" $report)}}
                    Annulation demandée, bonne journée !
                    {{deleteAllMessageReactions $reportLog $reportMessageID}}
                    {{addMessageReactions $reportLog $reportMessageID "🚫" "✅" "⚠️"}}
                    {{dbSet .User.ID "key" "used"}}
                {{end}}
            {{else}}
                {{$response := sendMessageRetID nil "Clé non valide fournie !"}}
                {{deleteMessage nil $response}}
            {{end}}
        {{end}}
        {{else}}
            {{$response := sendMessageRetID nil "Vous n'êtes pas l'auteur de ce report !"}}
            {{deleteMessage nil $response}}
    {{end}}
{{end}}