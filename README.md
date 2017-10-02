# ObjectiveC_Extension
Framework to add more features to Objective-C

## New features
I will make a list with the included features during the new days.

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


