{{/*Trigger : Command `nextcount`*/}}

{{$next := dbGet 118 "counter_count"}}
{{($next.Value)}}
{{deleteResponse}}