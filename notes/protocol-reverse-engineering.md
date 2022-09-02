# ANC modes

# Charge states
```
D: --[60:AA:*:*:*:7E] (Link Layer) received length: 20 data: 5a001000012701015a02035a640f0303000001bed9
I: --Is data from device: true, Handling data...
D: --[60:AA:*:*:*:7E] (VirtualDevice Layer) Receive response from Event => [null], current size: 0, command = 5a0127
W: --receiveResponse-mNotifyListeners:AudioDetail205251067
I: --onNotify batteryPercent = BatteryPercent{minBattery=90, arrayBattery=[90, 100, 15], timestamp=0, chargingState=[0, 0, 1]}
I: --onDeviceBatteryQuerySuccess
```

```
- 90, 100, 15 ; 0, 0, 1 => [90, 0, 16, 0, 1, 39, 1, 1, 90, 2, 3, 90, 100, 15, 3, 3, 0, 0, 1, 190, 217]
- 90, 100, 15 ; 0, 0, 0 => [90, 0, 16, 0, 1, 39, 1, 1, 90, 2, 3, 90, 100, 15, 3, 3, 0, 0, 0, 174, 248]
- 85, 100, 20 ; 0, 0, 1 => [90, 0, 16, 0, 1, 39, 1, 1, 85, 2, 3, 85, 100, 20, 3, 3, 0, 0, 1, 53, 14]
- 85, 100, 25 ; 0, 0, 1 => [90, 0, 16, 0, 1, 39, 1, 1, 85, 2, 3, 85, 100, 25, 3, 3, 0, 0, 1, 123, 77]
- 90, 100, 30 ; 0, 0, 0 => [90, 0, 16, 0, 1, 39, 1, 1, 90, 2, 3, 90, 100, 30, 3, 3, 0, 0, 0, 241, 220]
- 00, 100, 30 ; 0, 0, 0 => [90, 0, 16, 0, 1, 39, 1, 1, 100, 2, 3, 0, 100, 30, 3, 3, 0, 0, 0, 7, 249]
 

```
# Decompiled stuff
In `decompiledPlugin/assets/touchsetting/config_za08.json` i found info about touch settings:
```json
...
{
  "primaryText": "otter_touch_settings_previous",
  "hasDivider": true,
  "isLeftEar": true,
  "buttonType": 3,
  "selectedValue": 7
},
{
"primaryText": "fiji_touch_settings_wake_voice_assistant",
"hasDivider": true,
"isLeftEar": true,
"buttonType": 3,
"selectedValue": 0
},
...
```
The "selected value" number may be useful in figuring out the proto

This seems to help me with figuring out how to send noise ctrl functions:
```json
...
{
  "subTitleId": "hold_ear_noise_control_sub_title",
  "customView": "MultiUsageTextView",
  "isRefresh": true,
  "isGoneItem": true,
  "isSetGone": true,
  "noiseControlFunction": [2, 4, 3, 1],
  "itemBeans": [
    {
      "primaryText": "noise_reduction",
      "secondaryText": "block_external_sound",
      "hasDivider": true,
      "isNoiseControl": true,
      "selectedValue": 4,
      "buttonType": 2
    },
    {
      "primaryText": "base_none",
      "secondaryText": "off_and_pass_through",
      "hasDivider": true,
      "isNoiseControl": true,
      "selectedValue": 3,
      "buttonType": 2
    },
    {
      "primaryText": "base_pass_through",
      "secondaryText": "pass_through_external_voice",
      "hasDivider": false,
      "isNoiseControl": true,
      "selectedValue": 1,
      "buttonType": 2
    }
  ]
}
...
```

# Data sent by app at launch
When connecting, headphones not necessary instantly send us all data. I suppose there is some "give me the data" command. So this are first 3 commands sent by app at launch:
```
1662069336.29157 ---Sent---:
{ ServiceID: 1 CommandID: 7 }
Data: [1, 0, 2, 0, 3, 0, 4, 0, 5, 0, 6, 0, 7, 0, 8, 0, 9, 0, 10, 0, 11, 0, 12, 0, 15, 0, 25, 0]

1662069336.291772 ---Sent---:
{ ServiceID: 1 CommandID: 8 }
Data: [1, 0, 2, 0, 3, 0]

// Same service&command as "ANC status" command 👀
1662069336.291897 ---Sent---:
{ ServiceID: 43 CommandID: 42 }
Data: [1, 0]

1662069336.292109 ---Sent---:
{ ServiceID: 43 CommandID: 17 }
Data: [1, 0]
```

headphones then respond with some data, among others:
```
// Uknown
1662069336.292489 -Received-:
{ ServiceID: 1 CommandID: 7 }
Data: [2, 2, 1, 36, 3, 11, 72, 76, 49, 79, 84, 69, 77, 50, 95, 86, 66, 7, 9, 49, 46, 57, 46, 48, 46, 49, 57, 56, 9, 16, 85, 51, 85, 66, 66, 50, 49, 51, 48, 52, 49, 49, 51, 53, 56, 51, 10, 15, 66, 84, 70, 84, 48, 48, 48, 49, 45, 48, 48, 48, 49, 50, 52, 15, 8, 66, 84, 70, 84, 48, 48, 48, 49, 24, 16, 66, 66, 57, 68, 75, 68, 50, 49, 50, 51, 65, 48, 55, 57, 48, 49, 25, 1, 1]
// Battery data
1662069336.292745 -Received-:
{ ServiceID: 1 CommandID: 8 }
Data: [1, 1, 75, 2, 3, 75, 95, 20, 3, 3, 0, 0, 0]
// ANC status
1662069336.292813 -Received-:
{ ServiceID: 43 CommandID: 42 }
Data: [1, 2, 0, 0]  // stands for "off" (look at the wiki)
// uknown
1662069336.292876 -Received-:
{ ServiceID: 43 CommandID: 17 }
Data: [1, 1, 1]

```

i've sent the "{ ServiceID: 1 CommandID: 8 } Data: [1, 0, 2, 0, 3, 0]" to headphones, and it does respond! at same service=1 command=8. I've also sent it without any data, and it also works! Nice!!

"{ ServiceID: 43 CommandID: 42 }" also works to get anc! I will also remove data bytes because i don't know why whould need them

# Smart wear settings
When i open settings screen:
```
1662155578.941404 ---Sent---:
{ ServiceID: 43 CommandID: 17 }
Data: [1, 0]

1662155578.946794 ---Sent---:
{ ServiceID: 43 CommandID: 97 }
Data: [1, 0]

1662155578.961574 ---Sent---:
{ ServiceID: 43 CommandID: 143 }
Data: [1, 0]

1662155578.971868 -Received-:
{ ServiceID: 43 CommandID: 17 }
Data: [1, 1, 1]
```

Looks like it sends three requests, but gets back only one (43:17) - maybe there used to/there are on other models - other settings - and mine just don't have them

Anyway, looks like command (43:17) is to query smart-wear state. When i open the screen with it disabled, i get:
```
... same as before ...
1662155721.284483 -Received-:
{ ServiceID: 43 CommandID: 17 }
Data: [1, 1, 0]
```
...so only last byte signifies it being on/off

When clicking:
```
/// ON ///
1662158487.964747 ---Sent---:
{ ServiceID: 43 CommandID: 16 }
Data: [1, 1, 1]

1662158488.028921 -Received-:
{ ServiceID: 43 CommandID: 16 }
Data: [127, 4, 0, 1, 134, 160]

/// OFF ///
1662158512.064944 ---Sent---:
{ ServiceID: 43 CommandID: 16 }
Data: [1, 1, 0]

1662158512.349493 -Received-:
{ ServiceID: 43 CommandID: 16 }
Data: [127, 4, 0, 1, 134, 160]
```