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

### NSArray

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

### NSData

```objectivec
+(NSData*)dataWithContentsOfURL:(NSURL *)url timeoutInterval:(long long int)timeoutInterval;
```

Loads the content of an URL using `NSURLConnection` ignoring local cache data. It only provides you the data if no error happened during the download, and if the status code was between 200 and 299. A timeout can also be specified.

```objectivec
+(NSData*)safeDataWithContentsOfFile:(NSString*)filePath;
```

Init a `NSData` with the contents of the file at the specified path. Equivalent to `alloc` + `initWithContentsOfFile:options:error:`, but automatically prompts an error in case any happens, making your code cleaner and not ignoring any possible error.

```objectivec
+(NSString*)jsonStringWithJsonObject:(id)object;
```

Returns the contents of a JSON file based in an object (which may be a NSString, a NSArray, a NSDictionary or a NSNumber).

```objectivec
+(NSData*)dataWithJsonObject:(id)object;
```

Returns a `NSData` with the contents of a JSON file based in an object (which may be a NSString, a NSArray, a NSDictionary or a NSNumber).

```objectivec
-(id)jsonObject;
```

Returns an object based in the `NSData` object, which is the contents of a JSON file.

### NSDateFormatter

```objectivec
+(NSDate*)dateFromString:(NSString *)string withFormat:(NSString*)format;
```

Returns a `NSDate` object with the date specified in the string, which has the specified date format.

### NSFileManager

```objectivec
-(BOOL)createSymbolicLinkAtPath:(NSString *)path withDestinationPath:(NSString *)destPath;
```

Equivalent to `createSymbolicLinkAtPath:withDestinationPath:error:`, but automatically deals with any produced errors.

```objectivec
-(BOOL)createDirectoryAtPath:(NSString*)path withIntermediateDirectories:(BOOL)interDirs;
```

Equivalent to `createDirectoryAtPath:withIntermediateDirectories:attributes:error:`, but automatically deals with any produced errors and uses no attributes.

```objectivec
-(BOOL)createEmptyFileAtPath:(NSString*)path;
```

Equivalent to `createFileAtPath:contents:attributes:`, but with no contents and no attributes.

```objectivec
-(BOOL)moveItemAtPath:(NSString*)path toPath:(NSString*)destination;
```

Equivalent to `moveItemAtPath:toPath:error:`, but automatically deals with any produced errors.

```objectivec
-(BOOL)copyItemAtPath:(NSString*)path toPath:(NSString*)destination;
```

Equivalent to `copyItemAtPath:toPath:error:`, but automatically deals with any produced errors.

```objectivec
-(BOOL)removeItemAtPath:(NSString*)path;
```

Equivalent to `removeItemAtPath:error:`, but automatically deals with any produced errors.

```objectivec
-(BOOL)directoryExistsAtPath:(NSString*)path;
```

Equivalent to `fileExistsAtPath:isDirectory:`, but only returns true if the given path is a directory.

```objectivec
-(BOOL)regularFileExistsAtPath:(NSString*)path;
```

Equivalent to `fileExistsAtPath:isDirectory:`, but only returns true if the given path is not a directory.

```objectivec
-(NSArray*)contentsOfDirectoryAtPath:(NSString*)path;
```

Equivalent to `contentsOfDirectoryAtPath:error:`, but automatically deals with any produced errors.

```objectivec
-(NSString*)destinationOfSymbolicLinkAtPath:(NSString *)path;
```

Equivalent to `destinationOfSymbolicLinkAtPath:error:`, but automatically deals with any produced errors.

```objectivec
-(unsigned long long int)sizeOfRegularFileAtPath:(NSString*)path
```

Returns the size of the file at the given path according to the value of `NSFileSize` in the dictionary returned by `attributesOfItemAtPath:error:`.

```objectivec
-(unsigned long long int)sizeOfDirectoryAtPath:(NSString*)path
```

Returns the size of a directory by summing the size of regular files in subpaths inside the directory. Takes a longer time to run, but is much more precise.

```objectivec
-(NSString*)checksum:(NSString*)checksum ofFileAtPath:(NSString*)file
```

Returns the checksum of the specified file. The possible `checksum` values are "sha1" (40 digits) and "sha256" (64 digits).

### NSImage

```objectivec
+(NSImage*)imageWithData:(NSData*)data;
```

Init a `NSImage` with the contents of the `NSData` object.

```objectivec
+(NSImage*)quickLookImageFromFileAtPath:(NSString*)arquivo;
```

Init a `NSImage` with the QuickLook image of the file at the specified path.

```objectivec
+(NSImage*)imageFromFileAtPath:(NSString*)arquivo;
```

Init a `NSImage` with the contents of the image file at the specified path.

```objectivec
+(NSImage*)transparentImageWithSize:(NSSize)size;
```

Init a `NSImage` of an empty image with the specified size.

```objectivec
-(BOOL)saveAsIcnsAtPath:(NSString*)icnsPath;
```

Write the existing `NSImage` at the specified path in the icns (macOS icon) format.

```objectivec
-(BOOL)writeToFile:(NSString*)file atomically:(BOOL)useAuxiliaryFile;
```

Write the existing `NSImage` at the specified path in the format specified by the extension of the last component of the given path. Compatible extensions are **bmp**, **gif**, **jpg**, **jp2**, **png** and **tiff**.

## New Classes (misc)

### NSComputerInformation
Used to retrieve informations about the computer hardware and software.

```objectivec
+(NSDictionary*)graphicCardDictionary;
```

Dictionary with the informations available with the command `system_profiler SPDisplaysDataType` about the computer main graphic card. 

```objectivec
+(NSString*)graphicCardModel;
```

Model name of the computer main graphic card.

```objectivec
+(NSString*)graphicCardType;
```

Type of the computer main graphic card (Intel HD, Intel Iris, Intel GMA, NVIDIA or ATi/AMD). 

```objectivec
+(NSString*)graphicCardDeviceID;
```

Device ID of the computer main graphic card.

```objectivec
+(NSString*)graphicCardVendorID;
```

Vendor ID of the computer main graphic card.

```objectivec
+(NSString*)graphicCardMemorySize;
```

Memory size of the computer main graphic card.

```objectivec
+(NSString*)macOsVersion;
```

macOS version (not build version). Example: "10.13.1". Requires non-sandboxed application.

```objectivec
+(BOOL)isSystemMacOsEqualOrSuperiorTo:(NSString*)version;
```

Returns true if the user macOS version is equal or superior to the specified version. Requires non-sandboxed application.

```objectivec
IS_SYSTEM_MAC_OS_10_7_OR_SUPERIOR
IS_SYSTEM_MAC_OS_10_8_OR_SUPERIOR
IS_SYSTEM_MAC_OS_10_9_OR_SUPERIOR
IS_SYSTEM_MAC_OS_10_10_OR_SUPERIOR
IS_SYSTEM_MAC_OS_10_11_OR_SUPERIOR
IS_SYSTEM_MAC_OS_10_12_OR_SUPERIOR
IS_SYSTEM_MAC_OS_10_13_OR_SUPERIOR
```

Defines that use `isSystemMacOsEqualOrSuperiorTo:`. Requires non-sandboxed application.

```objectivec
+(BOOL)isUserStaffGroupMember;
```

Returns true if the user is member of the staff group in his computer.

### NSFTPManager

Replica of `FTPManager` by `nkreipke` with minor modifications. The original project can be found here:
https://github.com/nkreipke/FTPManager

