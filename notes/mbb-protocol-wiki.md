# Huawei MBB protocol
As known from de-compilation (and some logs) of the [Huawei AI Life app](https://consumer.huawei.com/pl/campaign/ai-life-app/), "MBB" is the name of the protocol that they use to communicate with headphones.

I did not found **ANY** information about this protocol/name *anywhere* - not on Github, nor on plain google search. Thus, all descriptions here will be very inconsistent, maybe unprofessional, and probably, biased because I only own one pair of FreeBuds 4i headphones - not pro's, or other versions.

However, I heaivliy tried to make everything as universal as I could. Enjoy!

## Messages structure
All data is transported using classic bluetooth serial port ([SPP](https://en.wikipedia.org/wiki/List_of_Bluetooth_profiles#Serial_Port_Profile_(SPP))).

Every "message" is just a list of bytes. After hours of observing them, I managed to partially figure out what purpose is of each byte.

Typical message looks like this:

`5a001000012701015a02035a640f0303000001bed9`

> This is actually a message with charge status: 90% left, 100% right, 15% case, and [0, 0, 1] - meaning lef and right buds not charging and case charging.

### Byte breakdown
Break it down to decimal bytes:

`90, 0, 16, 0, 1, 39, 1, 1, 90, 2, 3, 90, 100, 15, 3, 3, 0, 0, 1, 190, 217`

#### First two bytes
First byte/two bytes (`90, 0`) seem to be a "magic number" of protocol - they never change (at least on my single pair of headphones).

#### Third byte
Third byte - `16` - is the "length of data bytes - 1". You will see what "data bytes are" in a second.

#### Fourth byte
Next (fourth) byte seems to also always be 0

#### Fifth and sixth bytes
Fifth and sixth bytes are, according to app logs...
```
D: --[60:AA:*:*:*:7E] (VirtualDevice Layer) Receive response from Event => [SOF: 90 ServiceID: 1 CommandID: 8 TimeOut: 3000
    [90, 0, 16, 0, 1, 39, 1, 1, 90, 2, 3, 90, 100, 15, 3, 3, 0, 0, 1, 190, 217]
    ], current size: 0, command = 5a0127
```
..."ServiceID" and "CommandID" - they seem to signify what packet is all about. Notice the "`command = 5a0127`" - it seems to specify that `01` and `27` bytes (`1` and `39` in decimal) are particularly important. More on them will be in special sections.

The rest of the bytes seem to be "data bytes" - counted to [third "length" byte](#third-byte).

#### Middle bytes
Thus, rest of bytes contain actual data - whether it be battery level, or charging state, or something else - with exception of...

#### Last two bytes
<sub>With a sheer luck, I found out that...<sub>

They are a CTC16-Xmodem checksum 🎉 Just take the *whole* message (besides those two bytes of course), run them through this algo and there you have them!

> In my Dart code, I use [crclib](https://pub.dev/packages/crclib) package that provides a `Crc16Xmodem` class

You can check it on [online calculator (where I actually found out about it)](https://www.lammertbies.nl/comm/info/crc-calculation)


## Services
Below are IDs and their suspected purposes. They will also have detailed descriptions of CommandIDs and their usage, if any discovered.

### 1 - Battery service
Seems to be heavily related to battery.

#### CommandID=39 
Looks like a main juice that gives me levels etc.

While my headphones are 55%L, 65%R, 1%C, these are the data bytes:
`[1, 1, 55, 2, 3, 55, 65, 1, 3, 3, 0, 0, 0]`

So looks like 5th byte is left, 6th right and 7th case. Last 3 bytes are charging states, in same order (as I learned other time).

But that's with both buds out. If I put the left bud in case and close it, it gives me this:
`[1, 1, 65, 2, 3, 0, 65, 1, 3, 3, 0, 0, 0]`

I assume 0 means null, because it shows up placeholder "-" in the app, but why 55 changed to 65 in third byte?

When I've put the right bud, it showed this:
`[1, 1, 55, 2, 3, 55, 65, 1, 3, 3, 0, 0, 0]`

...SO, **I think** third byte is just highest charge there is 👀

> CommandID=8 also *sometimes* gives same bytes, but sometimes completely different, meanwhile 39 seems to be stable

### 43 - ANC service?
Seems to be related to ANC. All three commands to set anc to on, off, and transparency, have ServiceID=43 and CommandID=4

Data bytes look like this:
- `[1, 2, 1, 255]` for noise-canceling
- `[1, 2, 0, 0]` for off
- `[1, 2, 2, 255]` for transparency

I don't know what last `255`/`0` mean - maybe it's something like "strength" of the canceling? I tried to change them, but nothing changes... maybe it's something legacy/working on other headphones.

### 10 CommandID=13 - Party :tada:
This seems to be some kind of party mode. Hear me out. Those buds randomly start to span out shitload of those jsons:

```json
{"Type":"BTFT0001-000124|0x23|0x3e8","Time":0x630b17f2,"ID":0x4,"VID":0x16fe2498,"Ver":"1.9.0.198","Code":0x1,"SubCode":0x1}
{"Type":"BTFT0001-000124|0x24|0x3e9","Time":0x630b17f2,"ID":0x4,"Code":0x7,"SubCode":0x1}
{"Type":"BTFT0001-000124|0x27|0x3ea","Time":0x630b17f2,"ID":0x4,"VID":0x16fe2498,"Ver":"1.9.0.198","Code":0x4,"SubCode":0x0}
{"Type":"BTFT0001-000124|0x29|0x3eb","Time":0x630b17f2,"ID":0x4,"VID":0x16fe2498,"Ver":"1.9.0.198","Code":0x1,"SubCode":0xf}
{"Type":"BTFT0001-000124|0x2a|0x3ec","Time":0x630b17f2,"ID":0x4,"VID":0x16fe2498,"Ver":"1.9.0.198","Code":0x2,"SubCode":0xa}
```
(each one is separate payload)

It's actually super annoying when I try to watch other commands