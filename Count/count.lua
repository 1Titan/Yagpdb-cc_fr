{{/*Trigger : Regex `\A`*/}}

{{if not .ExecData}}
{{/* Main Counting Command */}}
{{/* If you are not doing (no twice msg in a row)  or (role assignment for latest user)  you can remove counter_user and by extension everything to do with $lastUser*/}}

{{/* First time running command, set up initial values*/}}
{{$lastUser := dbGet 118 "counter_user"}}
{{if $lastUser}}
{{else}}
{{dbSet 118 "counter_user" 0}}
{{dbSet 118 "counter_count" "0"}}
{{end}}

{{/* OPTIONAL: this is just to prevent one person to type all the numbers themselves */}}
{{/* If current user ID matches the user who last successfully ran command */}}
{{if eq (toFloat $lastUser.Value) (toFloat .User.ID)}}
{{deleteTrigger 1}}
{{sendDM "Vous ne pouvez pas envoyer de message deux fois d'affiler"}}
{{else}}


{{$next := dbGet 118 "counter_count"}}

{{/* If message is equal to the expected next number , update counter */}}
{{if and (eq (toInt .StrippedMsg) (toInt ($next.Value)))  (eq (len (toString .StrippedMsg)) (len (toString (toInt $next.Value)))) }}
{{dbSet 118 "counter_count" (add (toInt ($next.Value)) 1)}}

{{/* OPTIONAL count tracker per user, Delete if you don't want to use */}}
{{$key := joinStr "" "counter_tracker_"  .User.ID}}
{{$userCount := dbGet 118 $key}}
{{if $userCount}}
{{dbSet 118 $key (add (toInt ($userCount.Value)) 1)}}
{{else}}
{{dbSet 118 $key 1}}
{{end}}

{{/* OPTIONAL: If you don't want to give a role to the latest person delete everything but dbset */}}
{{/* Give new user role, take role back from old user and update latest user */}}
{{/* (UPDATE THE ROLEID) */}}

{{giveRoleID .User.ID 606891664396648474}}
{{$tmpUser := (userArg (toInt $lastUser.Value))}}
{{/* check if its a valid user or not */}}
{{if $tmpUser}} 
{{takeRoleID ($tmpUser.ID) 606891664396648474}}
{{end}}

{{/* OPTIONAL: If you don't want a channel topic goal tracker delete everything but dbset */}}
{{/*Goal Tracker in Topic */}}
{{$current := toInt (reFind `\d+` .Channel.Topic)}}
{{$list := cslice 15 20 25 30 50 75 100}}{{$found := false}}
{{$round := toInt (slice .StrippedMsg 0 1)}}
{{range $list}}{{if and (lt $round .) (not $found)}}{{$round = .}}{{$found = true}}{{end}}{{end}}
{{$res := toInt (mult $round (pow 10 (sub (len .StrippedMsg) 2)))}}
{{if not (eq $res $current)}}{{editChannelTopic nil (print "Goal : " $res " ; Chacun son tour ^^")}}{{end}}

{{dbSet 118 "counter_user" (toString .User.ID)}}
{{else}}

{{/* Message did not match expected next value */}}
{{deleteTrigger 1}}
{{/* Removed Because too annoying :^) */}}
{{/*sendDM "Ce n'est pas le prochain chiffre, apprends à compter :)"*/}}
{{end}}
{{end}}

{{/* Schedule auto cleanup to take care of any triggered commands */}}
{{scheduleUniqueCC .CCID nil 10 "clean" "clean"}}

{{else}}
{{/* Auto-Cleanup of triggered commands */}}
{{$s := execAdmin "clean 100 204255221017214977 -nopin"}}
{{end}}