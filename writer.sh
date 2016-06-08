#!/bin/sh

while sleep 1
do
	IFS=$(echo)
	QUERY='db.queue.mapReduce(function(){emit(this.event.replace(/lambda - request - /, ""), 1)}, function(key, values){var count = 0; values.forEach(function(v){count += v}); return count}, {query: {event: /lambda - request - (\w+)/, handled: false}, out: {inline: 1}}).results'
	echo "QUERY: $QUERY"
	RESPONSE=$(echo $QUERY | mongo mongo/mongomq | grep "\[")
	echo "RESPONSE: $RESPONSE"
	VALUES=$(echo $RESPONSE | perl -MMojo::JSON=from_json -le 'my $events = from_json join "", <>; for my $event(@$events) {print "lambda_queue_$event->{_id},type=lambda_queue,lambda=$event->{_id} value=$event->{value}"}')
	echo -e $VALUES
	for value in $VALUES
	do
		echo "WRITING: $value"
		curl -i -XPOST "http://influxdb:8086/write?db=fodocker" --data-binary "$value"
	done
	echo did
done

