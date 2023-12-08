# `framework/`

This folder contains **only** abstract classes with **no** logic - the framework for all implementations to base on

They will essentially contain all methods and properties that other classes need to implement.

Let's take `bluetooth_headphones.dart` as an example - it contains stuff that *all* bluetooth headphones (smart, or not smart) - *need* to implement:
- macAddress
- bluetoothName
- bluetoothAlias
- batteryLevel

Now, some concrete `GenericBluetoothHeaphones` class could implement `batteryLevel` based on classic bluetooth standards, while some `SmartHeadphones` could share the average value of left and right bud. `SmartHeadphones` would probably implement a bunch of other classes, but still have to provide all generic properties of `BluetoothHeadphones`.

# `simulators/`

Here are `mixin`s that can help you to quickly bake a simulator of a device

One headphones have ANC, others show battery for separate buds, others have both

But all of them implement classes for these properties one-by-one. Luckily, `simulators/` will contain simulating mixins for all these properties 🎉

```dart
// DONE!
final class AirPodsMaxSim extends AirPodsMax with ANCSim {}

// Also done!
final class CheapBudsSim extends CheapBuds with LRCBatterySim {}

// Even more done!!!
final class PoshBudsSim extends PoshBuds with ANCSim, LRCBatterySim{}
```

This is still kiiiiiinda boilerplate, but there may be properties that cannot be easily simulated with one-fits-all simulator, or you may want to do that manually

One could still say that `ANC` and `LRCBattery` classes could be simulations themselves, and just re-implement them in actual headphones' implementations - we would then avoid re-writing all of that `with`s - however, I just think it would be confusing, and could lead to weird bugs by someone forgetting to re-implement them.

And, this also allows us to make and mix multiple `Sim`s - for example, there would be just one fake `ANC`, while having `AlwaysFull`, `DischargingSlowly` and `ChargingFast` for the batteries 👀