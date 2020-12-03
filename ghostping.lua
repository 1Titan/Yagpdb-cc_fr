{{/*Trigger : Regex `.*`*/}}

{{$dp := true}}
{{if .ExecData}}
    {{$mentions := ""}}{{$ping := false}}
    {{if ($m := getMessage nil .ExecData.message)}}
    {{if $m.Mentions}}{{else}}{{$ping = true}}{{end}}
    {{else}}{{$ping = true}}{{end}}
    {{if $ping}}
    {{range .ExecData.mentions}}{{$mentions = print $mentions "<@" .ID "> "}}{{end}}

    {{/* Message to send when a ping is detected: */}}
    {{sendMessage nil (print "Ghost ping détecté par <@" .ExecData.author "> - " $mentions)}}

    {{else}}
    {{if $dp}}{{execCC .CCID nil 5 (sdict "message" .Message.ID "author" .Message.Author.ID "mentions" .Message.Mentions)}}{{end}}
    {{end}}
{{else}}
    {{if .Message.Mentions}}{{execCC .CCID nil 5 (sdict "message" .Message.ID "author" .Message.Author.ID "mentions" .Message.Mentions)}}{{end}}
{{end}}
