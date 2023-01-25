# Huawei MBB protocol
As known from de-compilation (and some logs) of the [Huawei AI Life app](https://consumer.huawei.com/pl/campaign/ai-life-app/), "MBB" is the name of the protocol that they use to communicate with headphones.

I did not found **ANY** information about this protocol/name *anywhere* - not on Github, nor on plain google search. Thus, all descriptions here will be very inconsistent, maybe unprofessional, and probably, biased because I only own one pair of FreeBuds 4i headphones - not pro's, or other versions.

However, I heaivliy tried to make everything as universal as I could. Enjoy!

**UPDATE**: Turned out there is this cool guy called [@melianmiko](https://melianmiko.ru/en) who also made app called [OpenFreebuds](https://github.com/melianmiko/OpenFreebuds). He kindly published pretty detailed descriptions of his rev-eng, which showed me quite few things I missed ; this wiki is much clearer thanks to him 😇 You can check him out! https://melianmiko.ru/en/posts/freebuds-4i-proto/

## Messages structure
All data is transported using classic bluetooth serial port ([SPP](https://en.wikipedia.org/wiki/List_of_Bluetooth_profiles#Serial_Port_Profile_(SPP))).

Every "message" is just a list of bytes. After hours of observing them, I managed to partially figure out what purpose is of each byte.

Typical message looks like this:

`5a001000012701015a02035a640f0303000001bed9`

> This is actually a message with charge status: 90% left, 100% right, 15% case, and case is currently charging

> [@melianmiko](https://melianmiko.ru/en) made very nice drawing of the breakdown:
> [![@melianmiko's breakdown drawing](https://melianmiko.ru/media/images/freebuds_pkg.original.png)](https://melianmiko.ru/en/posts/freebuds-4i-proto/#package-structure)
> (This is other message, not battery example)

### Byte breakdown
Break it down to decimal bytes:

`90, 0, 16, 0, 1, 39, 1, 1, 90, 2, 3, 90, 100, 15, 3, 3, 0, 0, 1, 190, 217`

#### First two bytes
First byte/two bytes (`90, 0`) seem to be a "magic number" of protocol - they never change (at least on my single pair of headphones).

#### Third byte
Third byte - `16` - is the "length of data bytes + checksum bytes + 1". You will see what "data bytes are" in a second.

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

The rest of the bytes seem to be "data bytes" + checksum bytes - counted to [third "length" byte](#third-byte).

```python
$ python
>>> # Bytes starting after service&command ids:
>>> len([1, 1, 90, 2, 3, 90, 100, 15, 3, 3, 0, 0, 1, 190, 217])
15  # +1 == 16 - the length byte!
```

#### Middle bytes
Thus, rest of bytes contain actual data, formed as arguments in [TLV schema](https://en.wikipedia.org/wiki/Type%e2%80%93length%e2%80%93value) - first byte is just incremental number of argument (starting from 1, not 0), second is its length, and the rest is the value.

> The TLV schema was discovered thanks to [@melianmiko's work](https://melianmiko.ru/en/posts/freebuds-4i-proto/#package-structure)

We can break down our "`[1, 1, 90, 2, 3, 90, 100, 15, 3, 3, 0, 0, 1]`" to:
- `1`'st arg, length `1` - `90` - lowest bud charge
- `2`'nd arg, length `3` - `90, 100, 15` - left+right+case charges
- `3`'rd arg, length `3` - `3, 3, 0` - left+right+case charging status

#### Last two bytes
<sub>With a sheer luck, I found out that...<sub>

They are a CTC16-Xmodem checksum 🎉 Just take the *whole* message (besides those two bytes of course), run them through this algo and there you have them!

> In my Dart code, I use [crclib](https://pub.dev/packages/crclib) package that provides a `Crc16Xmodem` class

You can check it on [online calculator (where I actually found out about it)](https://www.lammertbies.nl/comm/info/crc-calculation)

## Typical behaviour of commands
> When describing which service and command ids are used, I will write in "`(ServiceID:CommandID)`" format
> 
> I will later refer to this pair as "command", because it's shorter and clearer

> I will also describe data in format of TLV args, like `[(arg1byte1, arg1byte2), (arg2byte1), ...]` so it's shorter

Typically, for one property of headphones (anc mode, battery charge etc) there is some concrete `(ServiceID:CommandID)` command, but sometimes there are two commands that do almost the same 🤷

Sometimes, there are more arguments in the data than we actually need - it is probably because we don't know the rest of them - but we often don't need to know 😉

### Querying data
Usually, when you send the same command with empty data bytes, the headphones respond you with that command *with* the bytes - that's what I call that "you can **query** the data" 🚀 - so, if for example, you don't know the battery, just send them an empty battery command, and they will respond 😌
> Usually, when *the original app* does that, it sends `[1, 0]` as data bytes - but it perfectly works without it 👌

> There are some weird exceptions to those rules, which will be described

## Commands and data
Below are descriptions of different commands and ways to get/send info and settings

> Initially, I thought that same service id will group together similar stuff - but I find less ways to actually group them like that - so, below, all functionalities will be grouped in a human way, not "by service id" or something


### Battery
`(1:39)` is a main juice that updates levels etc - but, headphones send it "when they wish so 💅" (probably when level changes etc). They will not send you this info when you just connect to them. 

In order to query this (for example at app start), you need to use an empty `(1:8)` command - as I observed, it *usually* is *identical* to `(1:39)`, but *sometimes* it sends something irrelevant (3 args with 0 length, for example 🙃) - to protect and ignore that, just check if the length of data bytes

While my headphones are 55%L, 65%R, 1%C, these are data args:

`[(55), (55, 65, 1), (0, 0, 0)]`

But that's with both buds out. If I put the left bud in case and close it, it gives me this:

`[(65), (0, 65, 1), (0, 0, 0)]`

I assume 0 means null, because it shows up placeholder "-" in the app

"But why 55 changed to 65 in first arg?" - from my observation, first arg is just lowest (non-null) charged bud there is 👀

So we can assume arguments go like this:

| Length | Data                                  |
|--------|---------------------------------------|
| 1      | Lowest charged bud                    |
| 3      | left+right+case charge - in %         |
| 3      | left+right+case charging status - 0/1 |

TODO: Check if i can show args sequentially like this or if i need to specify index

### ANC
The command to change ANC mode to either on/off/transparency is `(43:4)`

Data args look like this:
- `[(1, 255)]` for noise-canceling
- `[(0, 0)]` for off
- `[(2, 255)]` for transparency

I don't know what last `255`/`0` mean - maybe it's something like "strength" of the canceling? I tried to change them, but nothing changes... maybe it's something legacy/working on other headphones.

BUT, headphones themselves report the current mode on separate command: `(43:42)`. Data args:
- `[(4, 1)]` for noise-canceling
- `[(0, 0)]` for off
- `[(0, 2)]` for transparency

They send this when you hold them, pull them out of your ear, and they even echo-style it back when you change the mode with app (with `(43:4)` command 🤯) - you can also query it (usual ["same command and empty data"](#querying-data)) 👍

Looks like second byte is the mode number, same as first one in CommandID=4. I don't know what first one does, but 🤷

### Smart wear setting
> This is another setting that has weird exceptions and different commands for the same thing 👎

To query it, use `(43:17)` with no args. I will respond (same command) with:
- `[(1)]` - smart wear on
- `[(0)]` - smart wear off

Now, if you want to change it, it gets tricky. You use `(43:16)` (pretty much the same):
- `[(1)]` - smart wear on
- `[(0)]` - smart wear off

TODO: Examine this (weird TLV index byte):

...BUT, it always (at least for me) responds with "`[127, 4, 0, 1, 134, 160]`" - both for off and on

So, to get consistent and certain info, I would suggest querying it *again* with `(43:17)` to check it 👍

### In-ear detection
While observing random commands, I found how headphones report they were put in/out of the ear - this may be super useful!

TODO: Examine this (weird TLV index byte):

`(43:3)` sends you this:
- `[9, 1, 1]` - right bud in ear
- `[9, 1, 0]` - right bud out of ear
- `[8, 1, 1]` - left bud in ear
- `[8, 1, 0]` - left bud out of ear

...so the `9` at first bud is for right, and `8` for left ; `1` at last one is for "in ear" and `0` for out 🎉

> Fun fact: If you want to query this with empty bytes, it will respond with `[0, 0, 0]` 😿
> > Actually, this *maybe* makes sense because this is "event command" (??) - it prints when it happens. Tho it could just print it again...

### `(10:13)` - Party :tada:
This seems to be some kind of party mode. Hear me out -t hose buds randomly start to span out shitload of those jsons:

```json
{"Type":"BTFT0001-000124|0x23|0x3e8","Time":0x630b17f2,"ID":0x4,"VID":0x16fe2498,"Ver":"1.9.0.198","Code":0x1,"SubCode":0x1}
{"Type":"BTFT0001-000124|0x24|0x3e9","Time":0x630b17f2,"ID":0x4,"Code":0x7,"SubCode":0x1}
{"Type":"BTFT0001-000124|0x27|0x3ea","Time":0x630b17f2,"ID":0x4,"VID":0x16fe2498,"Ver":"1.9.0.198","Code":0x4,"SubCode":0x0}
{"Type":"BTFT0001-000124|0x29|0x3eb","Time":0x630b17f2,"ID":0x4,"VID":0x16fe2498,"Ver":"1.9.0.198","Code":0x1,"SubCode":0xf}
{"Type":"BTFT0001-000124|0x2a|0x3ec","Time":0x630b17f2,"ID":0x4,"VID":0x16fe2498,"Ver":"1.9.0.198","Code":0x2,"SubCode":0xa}
```
(each one is separate payload)

It's actually super annoying when I try to watch other commands
