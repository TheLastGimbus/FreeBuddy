# Hello!

Nice to see you! This readme describes how freebuddy structures *the whole headphone stuff*, so it's a must-read for anyone wanting to implement new ones, or just looking around ^_^
 
Detecting paired headphones, managing serial/BLE connection with them, parsing their magic protocols, detecting available features - EVERYTHING is in here!! I did my **BEST** to organise that it's easy to understand, implement new models, find bugs and test 💪💪💪

## Quick wrap
Here's a quick roadmap of how headphones get connected:
1. Proper cubit watches over bluetooth itself - is it enabled? Is it even available? The ui listens to this cubit and displays proper info (for example, button leading to system bt settings if it's disabled)
   
   (This qubit may be a fake one to ease up testing without physical headphones - it then emits fake HeadphoneClass and we don't worry about any steps below)
2. TODO: Proper function/switch-case-loop watches over connected devices, distinguishes which ones are headphones that we support, then creates their object by passing them their bluetoothDevice + serial/BLE objects

   Note that this step already manages their serial connection - headphone classes assume they are connected
3. Given headphone class listens to all serial data, parses it and exposes all recognized info though it's streams. Almost every value - battery, name, anc state - has it's own `Stream`, and UI can be split to re-usable `StreamBuilder`s
4. When headphones get disconnected, function from step 2. closes the `StreamChannel` passed to HeadphoneClass, HpClass closes all it's streams and gets forgotten 💀

# `framework/`

This folder contains **only** abstract classes with **no** logic - the framework for all implementations to base on

They will essentially contain all methods and properties that other classes need to implement.

Let's take `bluetooth_headphones.dart` as an example - it contains stuff that *all* bluetooth headphones (smart, or not smart) - share in common and thus *need* to implement:
- macAddress
- bluetoothName
- bluetoothAlias
- batteryLevel

Now, some concrete `GenericBluetoothHeaphones` class could implement `batteryLevel` based on classic bluetooth standards, while some `SmartHeadphones` could share the average value of left and right bud. `SmartHeadphones` would probably implement a bunch of other classes, but still have to provide all generic properties of `BluetoothHeadphones`.

## `headphones_info.dart`

At some point, the freebuddy's code will contain some information about select headphones models - I want to avoid this as much as possible, since:
1. This stuff is language-specific, and implementing whole damn localisation for this is a no-no
2. Vendors often can't decide what is the freaking name/brand of their product (it is Xiaomi?? or Redmi? or Mi?? or both!)
3. Many more surprizes like different color of buds available on different markets etc
4. I want freebuddy to be very easy to extend - manually filling their names instead of getting them from bluetooth device name is another boilerplate step

So, I want to be careful with this, but for now adding their model and vendor name doesn't seem that bad 👀

# Vendor folders
Folders named by vendor - `huawei/`, `samsung/` etc contain headphones base classes, their implementations and simulators

## Base classes
Most basically named classes - f.e. `freebuds4i.dart` contain "blueprints/specifiactions" for headphones - have a look:
```dart
abstract base class HuaweiFreeBuds4i
    implements BluetoothHeadphones, HeadphonesModelInfo, LRCBattery, Anc {...}
```

We clearly see what features this model has - we use this class across UI, not caring how they are implemented

### Discoverability stuff in base classes
I don't have a better idea for where to put identifiers - that is, name regexes, bluetooth uuids etc (stuff that distinguishes given model from other bluetooth devices)

...so I'm putting it in static fields plainly in base classes 🤷 and later some big-ass switch will be like:

```dart
// example pseudocode
switch(device.btName) {
  case HuaweiFreeBuds4i.btName:
    return HuaweiFreeBuds4iImpl(device.rfComm);
  // ... etc
}
```

## Implementation classes
Classes named `SomeModelImpl` contain *THE* implementation - all bits and bytes parsing etc. Of course, you can extract some common-vendor stuff outside to share between models - this is up to you

These classes typically get already-connected bluetooth serial in form of `StreamChannel`

## Simulator classes
They are ready-to-use fake implementations of base classes - they are made with mixins from `simulators/`, and can be passed to ui instead of actual implementations 👍👍

# `simulators/`

`simulator` is my name for a mock - they are here to help you test the app without connecting the headphones, or even without Android/Bluetooth itself 

The folder contains `mixin`s that can help you to quickly bake a simulator of a device. The simulators themselves are actually located besides actual implementations of given headphones, not here

One headphones have ANC, others show battery for separate buds, others have both - but all of them implement classes for these properties one-by-one. Luckily, `simulators/` will contain simulating mixins for all these properties 🎉

```dart
// DONE!
final class AirPodsMaxSim extends AirPodsMax with ANCSim {}

// Also done!
final class CheapBudsSim extends CheapBuds with LRCBatterySim {}

// Even more done!!!
final class PoshBudsSim extends PoshBuds with ANCSim, LRCBatterySim{}
}
```

This is still kiiiiiinda boilerplate, but there may be properties that cannot be easily simulated with one-fits-all simulator, or you may want to do that manually

> One could still say that original/base `ANC` and `LRCBattery` classes could be simulations themselves, and just re-implement them in actual headphones' implementations - we would then avoid re-writing all of that `with`s - however, I just think it would be confusing, and could lead to weird bugs by someone forgetting to re-implement them.

And, this also allows us to make and mix multiple `Sim`s - for example, there would be just one fake `ANC`, while having `AlwaysFull`, `DischargingSlowly` and `ChargingFast` for the batteries 👀