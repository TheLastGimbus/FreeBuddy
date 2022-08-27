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