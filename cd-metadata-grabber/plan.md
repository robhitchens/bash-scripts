# Metadata grabber script plan

## Barcode scanner

> TLDR; allows user (me) to take picture of barcode, pulls barcode number from image, sends barcode off to be scanned by metadata service.

## Metadata query service

> TLDR; receives barcode, querys discogs, assembles message, publishes to queue

## Local service

> TLDR; local linux service that runs, pulls messages off of queue, assembles them into format for processing locally "manually".

## CD ripping script

> TLDR; script that ingests assembled metadata and queues up ripping script based on user input. Need config for specifying where to dump ripped cds.
