{{ $dec := randInt 0 16777216 }}
{{ $qEmbed := cembed 
"title" "Les Customs Commande sont :" "icon_url" "https://cdn.discordapp.com/attachments/685274628356177955/757691552276545586/image0.gif"
"description" "\n     **afk** {raison}{durée}\n     **mybirthday** {dd/mm/yyyy}\n     **topcount**\n     **gif** <name>\n     **google** <recherche>\n     **deathmatch** @user\n     **time**\n     **user**\n     **server**\n     **avatar**\n     **count**\n     **animal** <animal>\n     **choose** <texte>\n     **mock**"
"color" $dec
"footer" (sdict "text" (joinStr " " "Requested by:" (.User.Username))) "timestamp" currentTime}}

{{ sendMessage nil $qEmbed }}