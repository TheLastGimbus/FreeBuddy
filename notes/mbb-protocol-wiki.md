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

