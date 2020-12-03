{{/*Trigger : Command `gif`*/}}

{{$base_url := "https://giphy.com/search/"}}
{{$query := urlescape .StrippedMsg}}
{{$id := sendMessageRetID nil (print $base_url $query)}}
{{sleep 3}}
{{$Message := getMessage nil $id}}{{$del := false}}
{{with $Message.Embeds}}
    {{with (index . 0).Thumbnail}}
        {{if .Width}}
{{else}}{{$del := true}}
        {{end}}
    {{else}}{{$del := true}}
    {{end}}
{{else}}{{$del := true}}
{{end}}
{{if $del}}{{deleteMessage nil $id}}{{end}}