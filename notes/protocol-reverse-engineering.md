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