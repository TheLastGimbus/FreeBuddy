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
```

This is still kiiiiiinda boilerplate, but there may be properties that cannot be easily simulated with one-fits-all simulator, or you may want to do that manually

> One could still say that original/base `ANC` and `LRCBattery` classes could be simulations themselves, and just re-implement them in actual headphones' implementations - we would then avoid re-writing all of that `with`s - however, I just think it would be confusing, and could lead to weird bugs by someone forgetting to re-implement them.

And, this also allows us to make and mix multiple `Sim`s - for example, there would be just one fake `ANC`, while having `AlwaysFull`, `DischargingSlowly` and `ChargingFast` for the batteries 👀