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


## Extensions

### NSAlert

```objectivec
-(NSUInteger)runThreadSafeModal;
```

Equivalent to `runModal`, but always runs `NSAlert` in the main thread, avoiding concurrency problems.

```objectivec
+(NSUInteger)runThreadSafeModalWithAlert:(NSAlert* (^)(void))alert;
```

Lets you declared a `NSAlert` inside a block (which will run in the main thread) and returns its value. Equivalent to `runThreadSafeModal`, but lets you declare objects needed by your `NSAlert` in the main thread as well, avoiding concurrency problems.

```objectivec
+(void)showAlertMessageWithException:(NSException*)exception;
```

Creates an "Ok alert" with the useful information of a `NSException`. Very useful to reduce the size of `catch`es in try/catch. That alert uses the thread safe modal.

```objectivec
+(void)showAlertOfType:(NSAlertType)alertType withMessage:(NSString*)message;
```

Creates an "Ok alert" with the specified message, with a title and an icon defined by the `alertType` (Sucess, Warning, Error, Critical and Custom). That alert uses the thread safe modal.

```objectivec
+(void)showAlertMessage:(NSString*)message withTitle:(NSString*)title withSettings:(void (^)(NSAlert* alert))optionsForAlert;
```

Creates an "Ok alert" with the specified message and title, and lets you do anything with the alert in the block before running its modal. That alert uses the thread safe modal.

```objectivec
+(void)showAlertAttributedMessage:(NSAttributedString*)message withTitle:(NSString*)title withSubtitle:(NSString*)subtitle;
```

Creates an "Ok alert" with the specified title, subtitle and message, where the message is an attributed string. That alert uses the thread safe modal.

```objectivec
+(BOOL)showBooleanAlertMessage:(NSString*)message withTitle:(NSString*)title withDefault:(BOOL)yesDefault;
```

Creates an "Yes/No alert" with the specified title, message and default value (which will be the selectable key by pressing Return). That alert uses the thread safe modal.

```objectivec
+(BOOL)showBooleanAlertOfType:(NSAlertType)alertType withMessage:(NSString*)message withDefault:(BOOL)yesDefault;
```

Creates an "Yes/No alert" with the specified message and default value (which will be the selectable key by pressing Return), with a title and an icon defined by the `alertType` (Sucess, Warning, Error, Critical and Custom). That alert uses the thread safe modal.

```objectivec
+(BOOL)showBooleanAlertMessage:(NSString*)message withTitle:(NSString*)title withDefault:(BOOL)yesDefault withSettings:(void (^)(NSAlert* alert))setAlertSettings;
```

Creates an "Yes/No alert" with the specified title, message and default value (which will be the selectable key by pressing Return), and lets you do anything with the alert in the block before running its modal. That alert uses the thread safe modal.

```objectivec
+(BOOL)confirmationDialogWithTitle:(NSString*)prompt message:(NSString*)message withSettings:(void (^)(NSAlert* alert))setAlertSettings;
```

Creates an "Ok/Cancel alert" with the specified title and message, and lets you do anything with the alert in the block before running its modal. That alert uses the thread safe modal.

```objectivec
+(NSString*)inputDialogWithTitle:(NSString*)prompt message:(NSString*)message defaultValue:(NSString*)defaultValue;
```

Creates an "Ok/Cancel input alert" with the specified title, message and default value (which will be the initial value of the text input field of the alert). Any input provided in the field will be returned by the function. That alert uses the thread safe modal.

```objectivec
+(NSString*)showAlertWithButtonOptions:(NSArray*)options withTitle:(NSString*)title withText:(NSString*)text withIconForEachOption:(NSImage* (^)(NSString* option))iconForOption;
```

Creates an "Multiple buttons alert" with the specified title, message and options (which will become squared buttons with the icon specified in the block). The selected option will be returned by the function. That alert uses the thread safe modal.

### NSArrray

```objectivec
-(NSArray*)sortedDictionariesArrayWithKey:(NSString *)key orderingByValuesOrder:(NSArray*)value;
```

Returns a sorted version of an array of dictionaries based in the value of a key. The values are ordered according to the provided array of ordered possible values.

```objectivec
-(NSArray*)arrayByRemovingRepetitions;
```

Returns a copy of the existing array removing duplicates of the same element. Note: Doesn't preserve the order of the elements in the original array.

```objectivec
-(NSArray*)arrayByRemovingObjectsFromArray:(NSArray*)otherArray;
```

Returns a copy of the existing array, but without the elements that are present in the other array.

### NSAttributedString

```objectivec
-(instancetype)initWithHTMLData:(NSData*)data;
```

Init a `NSAttributedString` using a `NSData` with a HTML page inside.

```objectivec
-(instancetype)initWithHTMLString:(NSString*)string;
```

Init a `NSAttributedString` using a `NSString` with a HTML page.

```objectivec
-(NSString*)htmlString;
```

Returns an HTML page with the text and formatting of the `NSAttributedString` object.

### NSColor

```objectivec
RGBA(r,g,b,a)
```

Init a `NSColor` object with the specific levels of red, green, blue and alpha, from 0.0 to 255.0. Equivalent to `colorWithCalibratedRed:green:blue:alpha:`, but with a much smaller size.

```objectivec
RGB(r,g,b)
```

Init a `NSColor` object with the specific levels of red, green and blue, from 0.0 to 255.0. Equivalent to `RGBA(r,g,b,255.0)`.

```objectivec
+(NSColor*)colorWithHexColorString:(NSString*)inColorString;
```

Init a `NSColor` object with the color specified by a RGB hex string. Example: "000000" returns the black color.

```objectivec
-(NSString*)hexColorString;
```

Returns a RGB hex string of the `NSColor` object. Example: The black color returns "000000".



## New Classes (misc)

### NSComputerInformation
Used to retrieve informations about the computer hardware and software.


