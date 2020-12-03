{{/* Satff Roles */}}
        {{$Admins := cslice 779014497188839424}} {{/* IDs of your ADMINs Roles. Leave the "cslice" here even if you have only 1 role */}}
        {{$Mods := cslice 779014498673623060}} {{/* IDs of your MODs Roles. Leave the "cslice" here even if you have only 1 role */}}
        {{$MentionRoleID := 779014498673623060}} {{/* Role to be mentioned when a new ticket is opened */}}

    {{/* Open Message Info */}}
        {{$msgOpenChannelID := 780703485578182656}} {{/* Channel ID where the msg to open tickets is at. THIS CHANNEL CANT BE IN THE SAME CATEGORY AS THE TICKETS!!!!! */}}
        {{$msgID := 782304739320135711}} {{/* Message ID of the message the user has to react to open ticket */}}

    {{/* EMOJIS - Emoji MUST be unicode characters, like the examples here. */}}
        {{$OpenEmoji := "🎯"}}
        {{$CloseEmoji := "🔒"}}
        {{$SolveEmoji := "📌"}}
        {{$AdminOnlyEmoji := "🛡️"}}
        {{$ConfirmCloseEmoji := "✅"}} {{/* Closing the ticket with this system is a 2 step proccess. So, after you click the CloseEmoji, you can either confirm the closing or cancel it. */}}
        {{$CancelCloseEmoji := "❎"}}
        {{$SaveTranscriptEmoji := "📑"}}
        {{$ReOpenEmoji := "🔓"}}
        {{$DeleteEmoji := "⛔"}}

    {{/* Ticket Status */}}
        {{$ticketOpen := "Open"}} {{/* Status of an open ticket - CAN NOT HAVE ANY SPECIAL CHARACTERS OR SPACE */}}
        {{$ticketClose := "Closed"}} {{/* Status of a closed ticket - CAN NOT HAVE ANY SPECIAL CHARACTERS OR SPACE */}}
        {{$ticketSolving := "Solving"}} {{/* Status of an solving ticket - CAN NOT HAVE ANY SPECIAL CHARACTERS OR SPACE */}}

    {{/* Misc */}}
        {{$CCID := 48}} {{/* ID of your "Range CC" */}}
        {{$SchedueledCCID := 49}} {{/* ID of your "Schedueled CC" */}}
        {{$masterTicketChannelID := 779564947906363432}} {{/* A channel ID where the status of ur tickets will be displayed (Further explained in the README) */}}
        {{$Trc := 779402535630274560}} {{/* Channe ID to save transcripts */}}
        {{$category := 780221325822132224}} {{/* Tickets category ID */}}
        {{$Delay := 60}} {{/* Delay (in hours) for a ticket to automatically be deleted if no messages are sent */}}

{{/* END OF USER VARIABLES */}}



{{/* ACTUAL CODE! DONT TOUCH */}}
{{if not .ExecData}}
    {{$error := ""}}
    {{$guildRoles := cslice}} {{range .Guild.Roles}} {{$guildRoles = $guildRoles.Append .ID}} {{end}} {{$invalid := false}}

    {{if not $Admins}}
        {{$error = print $error "\n" "Vous devez définir au moins un rôle d'administrateur dans le **$Admins** variable"}}
    {{else}}
        {{range $Admins}}
            {{- if not (in $guildRoles .)}} {{$invalid = true}} {{end -}}
        {{end}}
        {{if $invalid}}
            {{$error = print $error "\n" "Un ou plusieurs des rôles d'administrateur fournis dans **$Admins** ne sont pas des rôles valides."}}
        {{end}}
    {{end}} {{$invalid = false}}


    {{if not $Mods}}
        {{$error = print $error "\n" "Vous devez définir au moins un rôle d'administrateur dans le **$Admins** variable"}}
    {{else}}
        {{range $Mods}}
            {{- if not (in $guildRoles .)}} {{$invalid = true}} {{end -}}
        {{end}}
        {{if $invalid}}
            {{$error = print $error "\n" "Un ou plusieurs des rôles de mod fournis dans **$Mods** ne sont pas des rôles valides."}}
        {{end}}
    {{end}}


    {{if not (in $guildRoles $MentionRoleID)}}
        {{$error = print $error "\n" "Le fourni **$MentionRoleID** n'est pas un rôle valide."}}
    {{end}}


    {{if not (getChannel $msgOpenChannelID)}}
        {{$error = print $error "\n" "Le **$msgOpenChannelID** fourni n'est pas un canal valide."}}
    {{end}}


    {{if not (getMessage $msgOpenChannelID $msgID)}}
        {{$error = print $error "\n" print "Le **$msgID** fourni n'est pas un msg valide ou n'est pas dans le <#" $msgOpenChannelID "> salon."}}
    {{end}}


    {{if or (reFind `[^a-zA-Z\d-]` $ticketOpen) (reFind `[^a-zA-Z\d-]` $ticketClose) (reFind `[^a-zA-Z\d-]` $ticketSolving)}}
        {{$error = "Mauvaise configuration.\n**$ticketOpen $ticketClose $ticketSolving** ne peut **PAS** avoir de caractères spéciaux comme `á` ou même des espaces blancs ` `.\nIls doivent aussi être un seul mot."}}
    {{end}}


    {{if not (toInt $CCID)}}
        {{$error = print $error "\n" "**$CCID** fourni doit être un int."}}
    {{end}}
    {{$s := exec "cc" $CCID}}
    {{if not (reFind `This is the "Range CC" command.` $s)}}
        {{$error = print $error "\n" "**$CCID** fourni n'est pas un CC valide"}}
    {{end}}


    {{if not (toInt $SchedueledCCID)}}
        {{$error = print $error "\n" "**$SchedueledCCID** fourni doit être un int."}}
    {{end}}
    {{$s := exec "cc" $SchedueledCCID}}
    {{if not (reFind `This is the "Schedueled CC" command.` $s)}}
        {{$error = print $error "\n" "**$SchedueledCCID** fourni n'est pas un CC valide"}}
    {{end}}


    {{if not (getChannel $masterTicketChannelID)}}
        {{$error = print $error "\n" "Le **$masterTicketChannelID** fourni n'est pas un canal valide."}}
    {{end}}


    {{if not (getChannel $Trc)}}
        {{$error = print $error "\n" "Le **$Trc** fourni n'est pas valide. Vous devez définir un canal approprié pour enregistrer les transcriptions."}}
    {{end}}


    {{if not (getChannel $category)}}
        {{$error = print $error "\n" "La **$category** fourni n'est pas une catégorie valide."}}
    {{end}}


    {{if $Delay}}
        {{if ne (printf "%T" $Delay) "int"}}
            {{$error = print $error "\n" "La variable **$Delay** doit être un entier. i.e 1, 2, 3, etc...\nCela ne peut pas être 2,75 par exemple"}}
        {{else if lt $Delay 1}}
            {{$error = print $error "\n" "La variable **$Delay** ne peut pas être inférieur à 1."}}
        {{end}}
    {{end}}


    {{if not $error}}
        {{addReactions $OpenEmoji $CloseEmoji $SolveEmoji $AdminOnlyEmoji $ConfirmCloseEmoji $CancelCloseEmoji $SaveTranscriptEmoji $ReOpenEmoji $DeleteEmoji}}
    {{end}}
    {{with $error}}
        {{.}}
    {{else}}
        {{$checkMsg := sendMessageRetID nil "Faire les dernières vérifications. Attend.\n**Si ce message n'est pas supprimé dans 6 secondes, cela signifie que $CCID et/ou $SchedueledCCID n'ont pas été réglés correctement.**"}}
        {{execCC $CCID nil 0 (sdict "test" "test" "id" $checkMsg "sch" $SchedueledCCID "thisCC" .CCID)}}
    {{end}}
{{else}}
{{dbDel 0 "ticketDisplay"}}
{{deleteMessage nil .ExecData.id 0}}
{{$id := sendMessageRetID $masterTicketChannelID (cembed "title" "Tickets Display" "color" (randInt 16777216))}}
{{dbSet 0 "ticket_cfg" (sdict "Admins" $Admins "Mods" $Mods "MentionRoleID" (str $MentionRoleID) "OpenEmoji" $OpenEmoji "CloseEmoji" $CloseEmoji "SolveEmoji" $SolveEmoji "AdminOnlyEmoji" $AdminOnlyEmoji "ConfirmCloseEmoji" $ConfirmCloseEmoji "CancelCloseEmoji" $CancelCloseEmoji "SaveTranscriptEmoji" $SaveTranscriptEmoji "ReOpenEmoji" $ReOpenEmoji "DeleteEmoji" $DeleteEmoji "ticketOpen" (lower $ticketOpen) "ticketClose" (lower $ticketClose) "ticketSolving" (lower $ticketSolving) "SchedueledCCID" (str $SchedueledCCID) "CCID" (str $CCID) "msgID" (str $msgID) "Trc" (str $Trc) "category" (str $category) "Delay" (str $Delay) "masterTicketChannelID" $masterTicketChannelID "displayMSGID" $id)}}
All good! If you did everything right, you should now be good to use your Reaction Ticket System! :)
{{$setup := sdict}} {{with (dbGet 0 "ticket_cfg").Value}} {{$setup = sdict .}} {{end}}
{{addMessageReactions $msgOpenChannelID $msgID $OpenEmoji}}
**Admins:** {{range $setup.Admins}} <@&{{.}}> {{end}}
**Mods:** {{range $setup.Mods}} <@&{{.}}> {{end}}
**RoleToBeMentionedWhenTicketIsOpened:** <@&{{toInt $setup.MentionRoleID}}>
**RangeCCID:** {{toInt $setup.CCID}}
**SchedueledCCID:** {{toInt $setup.SchedueledCCID}}
**TransCriptChannel:** <#{{toInt $setup.Trc}}>
**TicketsDisplayChannel:** <#{{toInt $setup.masterTicketChannelID}}>
**Category:** <#{{toInt $setup.category}}>
**MessageToOpenTicketID:** {{toInt $setup.msgID}}
**OpenEmoji:** {{$setup.OpenEmoji}}
**CloseEmoji:** {{$setup.CloseEmoji}}
**SolveEmoji:** {{$setup.SolveEmoji}}
**AdminOnlyEmoji:** {{$setup.AdminOnlyEmoji}}
**ConfirmCloseEmoji:** {{$setup.ConfirmCloseEmoji}}
**CancelCloseEmoji:** {{$setup.CancelCloseEmoji}}
**SaveTranscriptEmoji:** {{$setup.SaveTranscriptEmoji}}
**ReOpenEmoji:** {{$setup.ReOpenEmoji}}
**DeleteEmoji:** {{$setup.DeleteEmoji}}
**TicketOpenChannelStatus:** {{$setup.ticketOpen}}
**TicketSolvingChannelStatus:** {{$setup.ticketSolving}}
**TicketCloseChannelStatus:** {{$setup.ticketClose}}
**Delay (in hours):** {{toInt $setup.Delay}}
{{deleteResponse 120}}
{{end}}
{{deleteTrigger 7}}