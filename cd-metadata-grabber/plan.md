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

Command for creating named pipes is `mkfifo`. Looking at named pipes in linux it appears that they may not be exactly what I want to use, but will work for a simple POC for IPC.
Another alternative would be to create a helper script to manage a file as a queue with the following syntax:
```text
[ ] {jsonl} ([status])?
# below are example uses
[ ] {jsonl} [queued]
[x] {jsonl} [completed]
[-] {jsonl} [working]
[!] {jsonl} [failed]
```

Alternative:
```text
[ ] file-name ([status])?
# below are example uses
[ ] /tmp/queue/b84e0580-bd5b-4296-87ff-a97f330770a9 [queued]
[x] /tmp/queue/a9fea722-0d48-4060-abc6-b36dc0e880b0 [completed]
[-] /tmp/queue/3c77dcdf-7c63-42a2-8193-c4dfee97841b [working]
[!] /tmp/queue/1bc53960-f5ef-47d7-8693-f9813c1a000e [failed]
```
