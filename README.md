# ObjectiveC_Extension
Once I started developing my skills in Objective-C, I've noticed that while many things were pretty easy to do, others could be heavily simplified. I started with a `NSUtilities` class, which later became lots of extensions splitted in `+Extension` files. At some point, I had a separated folder for extensions and classes which I would import to almost every Objective-C project that I was involved.

In order to improve that, I've decided to create a framework with those classes and extensions, in order to optimize my work. It should be useful for a large range of projects, so feel free to use it, and enjoy :)

## New Classes (related with keycodes and devices)
Those classes were made to simplify the use of HID devices input, making your code cleaner when working with them, and more Objective-C-like, since most of the code related with that is C-like and C++-like. It also gives you enums to find the value of virtual keycodes (useful to simulate keyboard key pressing) and usage keycodes (useful to detect which keyboard key was pressed).

### CGVirtualKeycodes
A class which makes working with Mac Virtual Keycodes easier.

```objectivec
+(NSArray*)allKeyNames;
```

List of all the Mac Virtual Keycodes names.

```objectivec
+(NSDictionary*)virtualKeycodesNames;
```

Dictionary of the Mac Virtual Keycodes names by keycode.

```objectivec
+(NSString*)nameOfVirtualKeycode:(CGKeyCode)key;
```

Name of Mac Virtual Keycode by keycode.

```objectivec
+(void)performEventOfKeycode:(CGKeyCode)keyCode withKeyDown:(BOOL)keyPressed;
```

Simulates the button press/release of a Mac Virtual Keycode.

### IODeviceObserver
A class which makes working with HID devices easier.

```objectivec
+(instancetype)sharedObserver;
```

HID device observer shared instance.

```objectivec
-(void)observeDevicesOfTypes:(NSArray*)types forDelegate:(id<IODeviceObserverManagementDelegate>)actionDelegate;
```

Adds object that should receive notifications of observer.

```objectivec
-(void)stopObservingForDelegate:(id<IODeviceObserverManagementDelegate>)actionDelegate;
```

Makes an object stop receiving the observer notifications.

#### IODeviceObserverManagementDelegate (Protocol)

```objectivec
@property (nonatomic) IOHIDManagerRef hidManager;
```

Manager that makes any object capable of observing HID devices.

#### IODeviceObserverConnectionDelegate (Protocol)

```objectivec
-(void)observedConnectionOfDevice:(IOHIDDeviceRef)device;
```

Notify an object that a HID device has been connected.

```objectivec
-(void)observedRemovalOfDevice:(IOHIDDeviceRef)device;
```

Notify an object that a HID device has been disconnected.

#### IODeviceObserverActionDelegate (Protocol)

```objectivec
-(void)observedEventWithCookie:(IOHIDElementCookie)event andUsage:(uint32_t)usage withValue:(CFIndex)value fromDevice:(IOHIDDeviceRef)device;
```

Notify an object that a HID device has performed an event.

### IODeviceSimulator

```objectivec
+(void)simulateCursorClickAtScreenPoint:(CGPoint)clickPoint;
```

Simulates a mouse left button press at a screen point.

### IOKeycodeUsage

```objectivec
+(NSArray*)allUsageNames;
```

Name of keyboard keys that have a usage keycode.

```objectivec
+(NSDictionary*)keycodesUsageNames;
```

Name of keyboard keys by usage keycode.

```objectivec
+(NSString*)nameOfKeycodeUsage:(uint32_t)key;
```

Name of keyboard key with specific usage keycode.


