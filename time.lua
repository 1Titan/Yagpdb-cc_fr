{{/*Trigger : Command `time`*/}}

{{ $assets := sdict
    "matinée" (sdict
        "image" "https://www.bnrconvention.com/wp-content/uploads/2017/04/coffee-icon-1.png"
        "color" 9498256
    )
    "après-midi" (sdict
        "image" "https://www.bnrconvention.com/wp-content/uploads/2017/04/coffee-icon-1.png"
        "color" 16747520
    )
    "soirée" (sdict
        "image" "https://cdn4.iconfinder.com/data/icons/outdoors-3/460/night-512.png"
        "color" 8087790
    )
    "nuit" (sdict
        "image" "https://cdn4.iconfinder.com/data/icons/outdoors-3/460/night-512.png"
        "color" 1062054
    )
}} {{/* Only modify the individual sdicts, you should only be changing the image (url) or color (dec) */}}
{{ $timezone := "Europe/Paris" }} {{/* Avaliable from http://kevalbhatt.github.io/timezone-picker/ (same as setz) */}}
{{ $name := .User.Username }} {{/* Your name */}}
{{ $location := "Paris" }} {{/* City name */}}
{{/* CONFIGURATION VALUES END */}}
 
{{ $marker := "nuit" }}
{{ $output := exec "weather" $location }}
{{ $output = reReplace `\x60+` $output "" }}
{{ $res := split $output "\n" }}
{{ $weather := slice (index $res 3) 15 }}
{{ $temp := reReplace `\.\.` (reReplace ` \(.+$` (slice (index $res 4) 15) "") " - " }}
 
{{ $now := currentTime.In (newDate 0 0 0 0 0 0 $timezone).Location }}
{{ $hr := $now.Hour }}
{{ if and (ge $hr 5) (lt $hr 12) }} {{ $marker = "matiné" }}
{{ else if and (ge $hr 12) (lt $hr 17) }} {{ $marker = "après-midi" }}
{{ else if and (ge $hr 17) (lt $hr 21) }} {{ $marker = "soirée" }}
{{ end }}
 
{{ $asset := $assets.Get $marker }}
{{ $time := $now.Format "15h 04min 05s" }}
{{ $date := $now.Format "Monday 2 January 2006" }}
{{ $embed := cembed
    "title" (printf "Bonne %s, %s" $marker $name)
    "color" $asset.color
    "thumbnail" (sdict "url" $asset.image)
    "description" (printf "❯ **Heure :** %s\n❯ **Date :** %s\n❯ **Météo :** %s (%s)" $time $date $weather $temp)
}}
{{ sendMessage nil $embed }}