{{/*Trigger : Command `count`*/}}

{{$key := joinStr "" "counter_tracker_"  .User.ID}}

{{$count:= dbGet 118 $key}}
{{if $count}}
Tu as compté {{$count.Value}} fois.
{{else}}
Tu n'as pas encore compté, va compter dans <#779547936136495185> pour commencer.
{{end}}