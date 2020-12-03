{{/*Trigger : Reaction `Added + reactions`*/}}

{{$mRulesID := ID_MESSAGE}}
{{$mPingID := ID_MESSAGE}}

{{if eq .Reaction.MessageID $mRulesID}}
{{deleteMessageReaction nil $mRulesID .Reaction.UserID (print .Reaction.Emoji.Name ":" .Reaction.Emoji.ID)}}

{{else if eq .Reaction.MessageID $mPingID}}
{{deleteMessageReaction nil $mPingID .Reaction.UserID (joinStr "" .Reaction.Emoji.Name ":" .Reaction.Emoji.ID)}}

{{end}}