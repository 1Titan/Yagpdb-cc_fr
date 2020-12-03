{{/*Trigger : Command `giveaway`*/}}

{{$gEmoji:=`<a:Giveaway:779755248339648532>`}}

{{/*Code*/}}
{{$rEmoji:=reReplace `\A<|>\z` $gEmoji ""}}
{{$syntaxError:=0}}{{$CmdArgs:=cslice}}{{$StrippedMsg:=""}}{{$Cmd:=""}}{{$ExecData:=0}}
{{if not .ExecData}}{{$CmdArgs =.CmdArgs}}{{$StrippedMsg =reReplace `\A\s+|\s+\z` .StrippedMsg ""}}{{$Cmd =.Cmd}}
{{else if toInt .ExecData}}{{$ExecData =str .ExecData}}
{{else if eq (printf "%T" .ExecData) "string"}}
{{$args:=split .ExecData " "}}
{{if gt (len $args) 1}}
{{$StrippedMsg =reReplace `\A\s+|\s+\z` (joinStr " " (slice $args 1)) ""}}
{{$Cmd =index $args 0}}{{range reFindAllSubmatches `\x60(|.*?[^\\])\x60|"(|.*?[^\\])"|(\S+)` $StrippedMsg}}{{$CmdArgs =$CmdArgs.Append (or (index . 1) (index . 2) (index . 3))}}{{end}}{{$CmdArgs =$CmdArgs.StringSlice}}
{{end}}
{{end}}

{{if not $ExecData}}

{{if gt (len $CmdArgs) 0}}
{{$subCmd:=lower (index $CmdArgs 0)}}
{{if or (gt (len $CmdArgs) 1) (eq $subCmd "list") (eq $subCmd "reroll")}}

{{if eq $subCmd "start"}}

{{$CmdArgs:=reReplace (print `(?i)\A` $subCmd `\s*`) $StrippedMsg ""}}
{{$maxP:=-1}}{{$maxW:=1}}{{$chan:=.Channel.ID}}{{$ID:=""}}
{{$uID:=toInt (currentTime.Sub (newDate 2019 10 10 0 0 0)).Seconds}}

{{with reFindAllSubmatches `(?i)-w (\d+)(?:\s+|\z)` $CmdArgs}}{{$CmdArgs =reReplace (index . 0 0) $CmdArgs ""}}{{$maxW =toInt (index . 0 1)}}{{end}}
{{with reFindAllSubmatches `(?i)-p (\d+)(?:\s+|\z)` $CmdArgs}}{{$CmdArgs =reReplace (index . 0 0) $CmdArgs ""}}{{$maxP =toInt (index . 0 1)}}{{end}}
{{with reFindAllSubmatches `(?i)(-c (?:<#)?(\d+)>?(?:\s+|$))` $CmdArgs}}{{$CmdArgs =reReplace (index . 0 0) $CmdArgs ""}}{{$chan =index . 0 2}}{{end}}

{{$temp:=split $CmdArgs " "}}{{$duration:=toDuration (index $temp 0)}}{{$prize:=""}}
{{if gt (len $temp) 1}}{{$prize =joinStr " " (slice $temp 1)}}{{end}}
{{$prize =reReplace `\A\s+|\s+\z` $prize ""}}

{{if and $duration $prize}}

{{if or (ge $maxP $maxW) (eq $maxP -1)}}

{{with sendMessageNoEscapeRetID $chan cembed}}
{{$ID =joinStr "" $chan .}}{{$giveawaySdict:=sdict "chan" $chan "count" 0 "ID" $ID "listID" "" "maxWinners" $maxW "maxParticipants" $maxP "expiresAt" (currentTime.Add $duration) "prize" $prize "uID" $uID "host" $.User.Mention}}
{{addMessageReactions $chan . $rEmoji}}{{$desc:=print `>>> **Prix : **` $prize "\n\n"}}
{{if gt $maxW 0}}{{$desc =print $desc "**Gagnant :** " $maxW}}{{end}}{{if gt $maxP 0}}{{$desc =print $desc "⠀⠀⠀⠀⠀**Max Participants :** " $maxP}}{{end}}
{{$desc =print $desc "\n\n**Héberger par :** " $.User.Mention "\n\n**Réagis avec " $gEmoji " pour participer au Giveaway **"}}{{editMessage $chan . (cembed "title" "<:Weed:754457159227408495><a:Etoiles:754442162346655747>**Giveaway !!** <a:Etoiles:754442162346655747><:Weed:754457159227408495>" "description" $desc "color" 46837 "footer" (sdict "text" (print "Fini à ")) "timestamp" $giveawaySdict.expiresAt)}}

{{$dbData:=sdict (or (dbGet 7777 "giveaway_active").Value sdict)}}{{$dbData.Set $ID $giveawaySdict}}{{dbSet 7777 "giveaway_active" $dbData}}
{{$dbData =sdict (or (dbGet 7777 "giveaway_active_IDs").Value sdict)}}{{$dbData.Set (str $uID) $ID}}{{dbSet 7777 "giveaway_active_IDs" $dbData}}
{{scheduleUniqueCC $.CCID $chan $duration.Seconds $uID $ID}}

{{else}}
**Invalid Channel !!**
{{end}}
{{else}}
**Error:** Max Winners cannot be more than Max Participants!!
{{end}}
{{else}}
**Error:** Invalid Duration or Prize !!
{{end}}

{{else if eq $subCmd "end"}}
{{$uID:=index $CmdArgs 1}}
{{with (dbGet 7777 "giveaway_active").Value}}
{{$ID:=index (dbGet 7777 "giveaway_active_IDs").Value $uID}}
{{with (index . (str $ID))}}{{cancelScheduledUniqueCC $.CCID .uID}}{{$s:=sendTemplate .chan "g_end" "ID" (str $ID)}}

{{else}}
**Error:** Invalid ID ``{{$uID}}``
{{end}}
{{else}}
**Error:** Pas de Giveaways en cours.
{{end}}

{{else if eq $subCmd "cancel"}}
{{$uID:=index $CmdArgs 1}}{{$ID:=0}}

{{with (dbGet 7777 "giveaway_active").Value}}
{{$dbID:=(dbGet 7777 "giveaway_active_IDs").Value}}{{$ID =index $dbID $uID}}

{{with index . (str $ID)}}
{{$chan:=.chan}}{{$prize:=.prize}}{{$host:=.host}}{{cancelScheduledUniqueCC $.CCID .uID}}{{$msg:=index (split $ID (str $chan)) 1}}
{{with getMessage $chan $msg}}{{editMessage $chan $msg (cembed "title" "⛔<a:Etoile:754442181535727648> **Giveaway annuler !!** <a:Etoile:754442181535727648>⛔" "description" (print ">>> **<a:Etoile:754442181535727648>Prix :** " $prize "\n\n**Héberger : **" $host) "footer" (sdict "text" "Giveaway Cancelled") "color" 15954979)}}{{end}}Done!

{{else}}
**Error:** Invalid ID ``{{$uID}}``
{{end}}

{{if $ID}}
{{$newdbData:=sdict .}}{{$newdbData.Del $ID}}{{dbSet 7777 "giveaway_active" $newdbData}}
{{$newdbData =sdict $dbID}}{{$newdbData.Del $uID}}{{dbSet 7777 "giveaway_active_IDs" $newdbData}}
{{end}}

{{else}}
**Error:** No Active Giveaways.
{{end}}

{{else if eq $subCmd "reroll"}}
{{$ID:=1}}
{{if gt (len $CmdArgs) 1}}{{$ID =toInt (index $CmdArgs 1)}}{{end}}{{$found:=false}}

{{if ($e:=(dbGet 7777 "giveaway_old").Value)}}
{{range $i,$v:=$e}}{{if or (eq (sub (len $e) $i) $ID) (eq (toInt $v.uID) $ID)}}{{$found =true}}{{$s:=sendTemplate $v.chan "g_end" "ID" (str $v.ID) "Data" $v}}{{end}}
{{end}}
{{if not $found}}**Error** - Invalid Argument `{{index $CmdArgs 1}}`. Old Giveaway with corresponding ID or Position(1-10) not found!{{end}}

{{else}}
**Error:** No Old Giveaways.
{{end}}

{{else if eq $subCmd "list"}}

{{with (dbGet 7777 "giveaway_active").Value}}
{{$count:=0}}
{{range $k,$v:=.}}{{$count =add $count 1}}
{{$count}}) **ID :** ``{{$v.uID}}``  **Prix :** ``{{$v.prize}}``
**Fini à:** ``{{formatTime $v.expiresAt}}``
{{end}}

{{else}}
Pas de Giveaways en cours.
{{end}}

{{else}}
{{$syntaxError =1}}
{{end}}
{{else}}
{{$syntaxError =1}}
{{end}}
{{else}}
{{$syntaxError =1}}
{{end}}

{{else}}
{{$s:=sendTemplate nil "g_end" "ID" $ExecData}}
{{end}}

{{define "g_end"}}
{{$ID:=.TemplateArgs.ID}}{{$chan:=.Channel.ID}}{{$dbData:=(dbGet 7777 "giveaway_active").Value}}{{with .TemplateArgs.Data}}{{$dbData =sdict (str $ID) .}}{{end}}

{{if $dbData}}
{{with index $dbData $ID}}
{{$countWinners:=toInt .maxWinners}}{{$count:=toInt .count}}

{{if lt $count $countWinners}}{{$countWinners =$count}}{{end}}
{{$msg:=index (split $ID (str $chan)) 1}}{{$listID:=.listID}}

{{if and (gt $count .maxParticipants) (gt .maxParticipants 0)}}{{$count =.maxParticipants}}{{$listID =joinStr "," (slice (split $listID ",") 0 $count) ""}}{{end}}

{{$winnerList:=""}}
{{range seq 0 $countWinners}}{{$winner:=index (split $listID ",") (randInt 0 $count)}}{{$listID =reReplace (print $winner ",") $listID ""}}{{$count =add $count -1}}{{$winnerList =(print $winnerList "<@" $winner "> ")}}{{end}}

{{$desc:=print ">>> **Prix :** " .prize "\n\n**Gagnant :** "}}
{{if $countWinners}}{{$desc =print $desc $winnerList}}{{else}}{{$desc =print $desc "Pas de participants :( "}}{{end}}
{{$desc:=print $desc "\n\n**Héberger par :** " .host}}
{{with getMessage $chan $msg}}{{editMessage $chan $msg (cembed "title" "🎁<a:Etoile:754442181535727648> **Giveaway fini !!** <a:Etoile:754442181535727648>🎁" "description" $desc "footer" (sdict "text" "Fin ") "timestamp" currentTime "color" 12257822)}}{{end}}

{{if $countWinners}}{{sendMessage nil (print "**<a:Etoile:754442181535727648>Prix :** " .prize " 🍾\n**<a:Etoiles:754442162346655747>Gagnant(s) :** " $winnerList)}}
{{else}}
**<a:Etoiles:754442162346655747>Giveaway fini<a:Giveaway:779755248339648532>, pas de participants <a:Sad:754442145707851847> !**
**<a:Etoile:754442181535727648>Prix : {{.prize}}<a:Pepe_Awh:748488330206904441>**
{{end}}

{{if not $.TemplateArgs.Data}}
{{$newdbData:=sdict $dbData}}{{$newdbData.Del $ID}}{{dbSet 7777 "giveaway_active" $newdbData}}
{{$newdbData =sdict (dbGet 7777 "giveaway_active_IDs").Value}}{{$newdbData.Del (str .uID)}}{{dbSet 7777 "giveaway_active_IDs" $newdbData}}
{{$old:=cslice.AppendSlice (or (dbGet 7777 "giveaway_old").Value cslice)}}{{if gt (len $old) 9}}{{$old =slice $old 1}}{{end}}{{dbSet 7777 "giveaway_old" ($old.Append .)}}
{{end}}

{{else}}`Warning:` Invoked CC : {{$.CCID}} using ExecCC with invalid Giveaway ID.
{{end}}
{{else}}`Warning:` Invoked CC : {{$.CCID}} using ExecCC with no active Giveaways.
{{end}}

{{end}}

{{if $syntaxError}}{{sendMessage nil (print "__**Incorrect Syntax** __ \n**Commands are :** \n```elm\n" ($Cmd) " start <time : Duration> <prize : String> \n\noptional_flags \n-p (max participants : Number) \n-w (max winners : Number)\n-c (channel : Mention/ID)\n```\n```elm\n" ($Cmd) " end <id : Number>```\n```elm\n" ($Cmd) " cancel <id : Number>```\n```elm\n" ($Cmd) " reroll [id or n giveaways old : Number]```\n```elm\n" ($Cmd) " list ``` ")}}{{end}}
{{deleteTrigger}}