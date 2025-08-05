# Metadata grabber script plan

## Barcode scanner

> TLDR; allows user (me) to take picture of barcode, pulls barcode number from image, sends barcode off to be scanned by metadata service.

## Metadata query service

> TLDR; receives barcode, querys discogs, assembles message, publishes to queue

## Local service

> TLDR; local linux service that runs, pulls messages off of queue, assembles them into format for processing locally "manually".

## CD ripping script

> TLDR; script that ingests assembled metadata and queues up ripping script based on user input. Need config for specifying where to dump ripped cds.


## Toy Bash Script POC

May look at utilizing FIFO files to act as the queues for the end-to-end processing pipeline. If I can find a javascript library or WASM library to read barcodes then I can also prototype the user interface as a simple web page/service or PWA, will still need a local hook to handle passing along barcode and sending back ack.

Since most of this process can be asynchronous message passing; we might be able to utilize multiple queues. How that scales from local concept to cloud services idk. I guess I'll have to workshop that idea.

Command for creating named pipes is `mkfifo`
