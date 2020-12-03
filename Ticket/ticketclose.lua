{{/*Trigger : Command `ticket close`*/}}

{{dbDel .User.ID "ticket"}}