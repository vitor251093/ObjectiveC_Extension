# ObjectiveC_Extension
Framework to add more features to Objective-C

## New features
I will make a list with the included features during the new days.

### CGVirtualKeycodes
A class which makes working with Mac Virtual Keycodes easier.

- `+(NSArray*)allKeyNames;`

List of all the Mac Virtual Keycodes names.

- `+(NSDictionary*)virtualKeycodesNames;`

Dictionary of the Mac Virtual Keycodes names by keycode.

- `+(NSString*)nameOfVirtualKeycode:(CGKeyCode)key;`

Name of Mac Virtual Keycode by keycode.

- `+(void)performEventOfKeycode:(CGKeyCode)keyCode withKeyDown:(BOOL)keyPressed;`

Simulates the button press/release of a Mac Virtual Keycode.

### IODeviceObserver
A class which makes working with HID devices easier.

- `+(instancetype)sharedObserver;`

HID device observer shared instance.

- `-(void)observeDevicesOfTypes:(NSArray*)types forDelegate:(id<IODeviceObserverManagementDelegate>)actionDelegate;`

Adds object that should receive notifications of observer.

- `-(void)stopObservingForDelegate:(id<IODeviceObserverManagementDelegate>)actionDelegate;`

Makes an object stop receiving the observer notifications.

#### IODeviceObserverManagementDelegate (Protocol)

- `@property (nonatomic) IOHIDManagerRef hidManager;`

Manager that makes any object capable of observing HID devices.

#### IODeviceObserverConnectionDelegate (Protocol)

- `-(void)observedConnectionOfDevice:(IOHIDDeviceRef)device;`

Notify an object that a HID device has been connected.

- `-(void)observedRemovalOfDevice:(IOHIDDeviceRef)device;`

Notify an object that a HID device has been disconnected.

#### IODeviceObserverActionDelegate (Protocol)

- `-(void)observedEventWithCookie:(IOHIDElementCookie)event andUsage:(uint32_t)usage withValue:(CFIndex)value fromDevice:(IOHIDDeviceRef)device;`

Notify an object that a HID device has performed an event.


