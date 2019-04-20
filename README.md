# ObjectiveC_Extension

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

Once I started developing my skills in Objective-C, I've noticed that while many things were pretty easy to do, others could be heavily simplified. I started with a `NSUtilities` class, which later became lots of extensions splitted in `+Extension` files. At some point, I had a separated folder for extensions and classes which I would import to almost every Objective-C project that I was involved.

In order to improve that, I've decided to create a framework with those classes and extensions, in order to optimize my work. It should be useful for a large range of projects, so feel free to use it, and enjoy :)

**IMPORTANT WARNING:** When using this project, configure the `ObjCExtensionConfig.h` file according to your needs. Don't worry, it takes just some seconds.

## Compatibility
This is the best part of that framework. ObjectiveC_Extension is compatible with every version of macOS still compatible with Xcode 9, so it is compatible with macOS 10.6+. Obviously, that requires some workarounds and *hacks*. They will be listed in the end of that document.

## New Classes (related with keycodes and devices)
Those classes were made to simplify the use of HID devices input, making your code cleaner when working with them, and more Objective-C-like, since most of the code related with that is C-like and C++-like. It also gives you enums to find the value of virtual keycodes (useful to simulate keyboard key pressing) and usage keycodes (useful to detect which keyboard key was pressed).

### VMMVirtualKeycodes
A class which makes working with Mac Virtual Keycodes easier.

```objectivec
+(NSArray*)allKeyNames;
```

List of all the Mac Virtual Keycodes names.

```objectivec
+(NSDictionary*)virtualKeycodeNames;
```

Dictionary of the Mac Virtual Keycodes names by keycode.

```objectivec
+(NSString*)nameOfVirtualKeycode:(CGKeyCode)key;
```

Name of Mac Virtual Keycode by keycode.

### VMMDeviceSimulator
A class which simulate keyboard and cursor actions.

```objectivec
+(void)simulateCursorClickAtScreenPoint:(CGPoint)clickPoint
```

Simulates the mouse left-click on a specific screen point moving the cursor.

```objectivec
+(void)simulateVirtualKeycode:(CGKeyCode)keyCode withKeyDown:(BOOL)keyPressed;
```

Simulates the button press/release of a Mac Virtual Keycode.

### VMMDeviceObserver
A class which makes working with HID devices easier.

```objectivec
+(instancetype)sharedObserver;
```

HID device observer shared instance.

```objectivec
-(void)observeDevicesOfTypes:(NSArray*)types forDelegate:(id<VMMDeviceObserverDelegate>)actionDelegate;
```

Adds object that should receive notifications of observer.

```objectivec
-(void)stopObservingForDelegate:(id<VMMDeviceObserverDelegate>)actionDelegate;
```

Makes an object stop receiving the observer notifications.

#### VMMDeviceObserverDelegate (Protocol)
Protocol for `VMMDeviceObserver` delegate. All the methods below are optionals. The only thing mandatory is the `hidManager` property.

```objectivec
@property (nonatomic) IOHIDManagerRef hidManager;
```

Manager that makes any object capable of observing HID devices.

```objectivec
-(void)observedConnectionOfDevice:(IOHIDDeviceRef)device;
```

Notify an object that a HID device has been connected.

```objectivec
-(void)observedRemovalOfDevice:(IOHIDDeviceRef)device;
```

Notify an object that a HID device has been disconnected.

```objectivec
-(void)observedEventWithName:(CFStringRef)name cookie:(IOHIDElementCookie)cookie usage:(uint32_t)usage value:(CFIndex)value device:(IOHIDDeviceRef)device;
```

Notify an object that a HID device has performed an event.

```objectivec
-(void)observedReportWithID:(uint32_t)reportID data:(nonnull uint8_t*)report type:(IOHIDReportType)reportType length:(CFIndex)reportLength device:(nonnull IOHIDDeviceRef)device;
````

Notify an object that a HID device has reported something.

### VMMUsageKeycode

```objectivec
+(NSArray*)allUsageNames;
```

Name of keyboard keys that have a usage keycode.

```objectivec
+(NSDictionary*)usageNamesByKeycode;
```

Name of keyboard keys by usage keycode.

```objectivec
+(NSString*)nameOfUsageKeycode:(uint32_t)key;
```

Name of keyboard key with specific usage keycode.


## Extensions

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

### NSApplication

```objectivec
+(void)restart;
```

Restarts the application.

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

### NSBundle

```objectivec
-(nonnull NSString*)bundleName;
```

Returns the name of the bundle. It returns the first non-nil value from those: CFBundleDisplayName from Info.plist, CFBundleName from Info.plist, `getprogname()`, the bundle path last component with no extension, `@"App"`.

```objectivec
-(nullable NSImage*)bundleIcon;
```

Returns the icon of the bundle.

```objectivec
-(BOOL)isAppTranslocationActive;
```

Checks if the app is being executed in App Translocation.

```objectivec
-(BOOL)disableAppTranslocation;
```

Disable App Translocation in the app at the bundle path.

```objectivec
+(nullable NSBundle*)originalMainBundle;
```

Returns the `NSBundle` of the original bundle, not App Translocated, in case the app is App Translocated. If the app isn't App Translocated, it returns the `mainBundle`.

### NSColor

```objectivec
RGBA(r,g,b,a)
```

Init a `NSColor` object with the specific levels of red, green, blue and alpha, from 0.0 to 255.0. Equivalent to `colorWithDeviceRed:green:blue:alpha:`, but with a much smaller size.

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
-(NSString*)checksum:(NSChecksumType)checksum ofFileAtPath:(NSString*)file
```

Returns the checksum of the specified file. There are 14 possible cryptographies for `checksum`, including sha1, sha256, md5, etc.

### NSImage

```objectivec
+(NSImage*)imageWithData:(NSData*)data;
```

Init a `NSImage` with the contents of the `NSData` object.

```objectivec
+(NSImage*)quickLookImageWithMaximumSize:(int)size forFileAtPath:(NSString*)arquivo
```

Init a `NSImage` with the QuickLook image of the file at the specified path with the specified size (or smaller).

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

Changes the color of an existing `NSMenu` to the dark color of the Dock right-click menu.

### NSMenuItem

```objectivec
+(NSMenuItem*)menuItemWithTitle:(NSString*)title andAction:(SEL)action forTarget:(id)target;
```

Equivalent to `alloc` + `initWithTitle:action:keyEquivalent:` + `setTarget:`, with key equivalent equals to `@""`. Used to make the code cleaner.


## New Classes (misc)

### VMMAlert

```objectivec
-(NSUInteger)runThreadSafeModal;
```

Equivalent to `runModal`, but always runs `VMMAlert` in the main thread, avoiding concurrency problems.

```objectivec
+(NSUInteger)runThreadSafeModalWithAlert:(VMMAlert* (^)(void))alert;
```

Lets you declared a `VMMAlert` inside a block (which will run in the main thread) and returns its value. Equivalent to `runThreadSafeModal`, but lets you declare objects needed by your `VMMAlert` in the main thread as well, avoiding concurrency problems.

```objectivec
+(void)showAlertMessageWithException:(NSException*)exception;
```

Creates an "Ok alert" with the useful information of a `NSException`. Very useful to reduce the size of `catch`es in try/catch. That alert uses the thread safe modal.

```objectivec
+(void)showAlertOfType:(VMMAlertType)alertType withMessage:(NSString*)message;
```

Creates an "Ok alert" with the specified message, with a title and an icon defined by the `alertType` (Sucess, Warning, Error, Critical and Custom). That alert uses the thread safe modal.

```objectivec
+(void)showAlertMessage:(NSString*)message withTitle:(NSString*)title withSettings:(void (^)(VMMAlert* alert))optionsForAlert;
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
+(BOOL)showBooleanAlertOfType:(VMMAlertType)alertType withMessage:(NSString*)message withDefault:(BOOL)yesDefault;
```

Creates an "Yes/No alert" with the specified message and default value (which will be the selectable key by pressing Return), with a title and an icon defined by the `alertType` (Sucess, Warning, Error, Critical and Custom). That alert uses the thread safe modal.

```objectivec
+(BOOL)showBooleanAlertMessage:(NSString*)message withTitle:(NSString*)title withDefault:(BOOL)yesDefault withSettings:(void (^)(VMMAlert* alert))setAlertSettings;
```

Creates an "Yes/No alert" with the specified title, message and default value (which will be the selectable key by pressing Return), and lets you do anything with the alert in the block before running its modal. That alert uses the thread safe modal.

```objectivec
+(BOOL)confirmationDialogWithTitle:(NSString*)prompt message:(NSString*)message withSettings:(void (^)(VMMAlert* alert))setAlertSettings;
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

### VMMComputerInformation
Used to retrieve informations about the computer hardware and software.

```objectivec
+(long long int)hardDiskSize;
```

Hard disk size in bytes. Requires non-sandboxed application.

```objectivec
+(long long int)hardDiskFreeSize;
```

Hard disk free size (available space) in bytes. Requires non-sandboxed application.

```objectivec
+(long long int)hardDiskUsedSize;
```

Hard disk used size (non-available space) in bytes. Requires non-sandboxed application.

```objectivec
+(long long int)ramMemorySize;
```

RAM memory size in bytes.

```objectivec
+(long long int)ramMemoryFreeSize
```

RAM memory free size (available space) in bytes. Requires non-sandboxed application.

```objectivec
+(long long int)ramMemoryUsedSize
```

RAM memory used size (non-available space) in bytes. Requires non-sandboxed application.

```objectivec
+(nullable NSString*)processorNameAndSpeed;
```

Processor name and speed. Requires non-sandboxed application.

```objectivec
+(double)processorUsage;
```

Processor usage percentage (from 0.0 to 1.0). Requires non-sandboxed application.

```objectivec
+(nullable NSString*)macModel;
```

Mac model. Requires non-sandboxed application.

```objectivec
+(NSString*)macOsVersion;
```

macOS version. Example: "10.13". Requires non-sandboxed application.

```objectivec
+(nullable NSString*)completeMacOsVersion;
```

macOS complete version. Example: "10.13.1". Requires non-sandboxed application.

```objectivec
+(NSString*)macOsBuildVersion;
```

macOS build version. Example: "17C60c". Requires non-sandboxed application.

```objectivec
+(BOOL)isSystemMacOsEqualOrSuperiorTo:(NSString*)version;
```

True if the user macOS version is equal or superior to the specified version. Requires non-sandboxed application.

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
+(BOOL)isUserMemberOfUserGroup:(VMMUserGroup)userGroup;
```

True if the user is member of a specific user group in his computer.

```objectivec
+(NSArray<VMMVideoCard*>* _Nonnull)videoCards;
```

List of the computer video cards. Possibly requires non-sandboxed application.

```objectivec
+(VMMVideoCard* _Nullable)bestVideoCard;
```

Most powerful video card of the computer. Possibly requires non-sandboxed application.

### VMMVideoCard
Model that stores information about a specific video card.

```objectivec
-(nonnull NSDictionary*)dictionary;
```

Dictionary with the informations about the video card.

```objectivec
-(nullable NSString*)name;
```

Name (model) of the video card.

```objectivec
-(nullable NSString*)type;
```

Type of the video card (Intel HD, Intel Iris, Intel Iris Pro, Intel Iris Plus, Intel GMA, NVIDIA or ATI/AMD).

```objectivec
-(nullable NSString*)bus;
```

Bus of the video card (Built-In, PCI or PCIe).

```objectivec
-(nullable NSString*)deviceID;
```

Device ID of the video card.

```objectivec
-(nullable NSString*)vendorID;
```

Vendor ID of the video card.

```objectivec
-(nullable NSString*)vendor;
```

Vendor of the video card (NVIDIA, ATI/AMD, Intel, etc).

```objectivec
-(nullable NSNumber*)memorySizeInMegabytes;
```

Memory size of the video card.

```objectivec
-(BOOL)supportsMetal;
```

Returns true if the video card supports Metal.

```objectivec
-(VMMMetalFeatureSet)metalFeatureSet;
```

Returns the MTLFeatureSet value of the video card, without using the Metal framework. Although, the returned values are equivalent to their MTLFeatureSet counterparts.

```objectivec
-(nonnull NSString*)descriptorName;
```

Identifier of the video card. It contains the model, type, vendor or vendor ID (depending of which ones is available) and the memory size, if available.

```objectivec
-(BOOL)isReal;
```

Returns true if the video card vendor is Intel, ATI/AMD or NVIDIA.

```objectivec
-(BOOL)isComplete;
```
Returns true if it was possible to retrieve the most relevant informations about the video card (name, device ID and memory size).

```objectivec
-(BOOL)isVirtualMachineVideoCard;
```
Returns true if the video card is a mock created by a virtual machine, like VirtualBox, VMware, Parallels Desktop or Qemu.

### VMMParentalControls
Used to check if there is any Parental Control restrictions to the actual user.

```objectivec
+(BOOL)isEnabled;
```

Check if Parental Controls are enabled for the actual users.

```objectivec
+(BOOL)iTunesMatureGamesAllowed;
```

Return `true` if the user is allowed to play mature rated games.

```objectivec
+(VMMParentalControlsItunesGamesAgeRestriction)iTunesAgeRestrictionForGames;
```

Return the user age restriction for games (None, 4+, 9+, 12+ or 17+).

```objectivec
+(BOOL)isAppRestrictionEnabled;
```

Return `true` if the user is restricted to use only specific apps.

```objectivec
+(BOOL)isAppUseRestricted:(NSString*)appPath;
```

Return `false` if the user is allowed to use the app at the specified path.

```objectivec
+(BOOL)isInternetUseRestricted;
```

Return `true` if the user internet access is restricted in some way.

```objectivec
+(BOOL)isWebsiteAllowed:(NSString*)websiteAddress;
```

Return `true` if the user can access a specific web address.


### VMMUserNotificationCenter
Replacement for `NSUserNotificationCenter`, which uses `NSUserNotificationCenter` if available, but still shows the message in macOS 10.6 and 10.7.

```objectivec
+(nonnull instancetype)defaultUserNotificationCenter;
```

Shared instance of `VMMUserNotificationCenter`.

```objectivec
@property (nonatomic, nullable) id<VMMUserNotificationCenterDelegate> delegate;
```

Delegate of the `VMMUserNotificationCenter` instance.

```objectivec
+(BOOL)isGrowlEnabled;
```

Checks if the use of Growl to send notifications is enabled or not. Growl is enabled by default only if the macOS version is 10.7- and Growl is available.

```objectivec
+(void)setGrowlEnabled:(BOOL)enabled;
```

Force `VMMUserNotificationCenter` to use Growl. That may result in an error if Growl is unavailable.

```objectivec
+(BOOL)isGrowlAvailable;
```

Check if Growl is installed in the user machine.

```objectivec
-(BOOL)deliverGrowlNotificationWithTitle:(nullable NSString*)title message:(nullable NSString*)message icon:(nullable NSImage*)icon;
```

Sends Growl notification with a specific title, message and icon. An icon can only be used in macOS 10.6. The function returns `true` if the notification was shown succesfully.

```objectivec
-(void)deliverNotificationWithTitle:(nullable NSString*)title message:(nullable NSString*)message userInfo:(nullable NSObject*)info icon:(nullable NSImage*)icon actionButtonText:(nullable NSString*)actionButton;
```

Sends a notification with a specific title, message and icon, with an user information and a title for the action button. It sends a Growl notification only if it's enabled. If it's disabled, a `NSUserNotificationCenter`  notification if it's available; otherwise, it shows a regular `NSAlert` with the message. That function warranties that the user will receive the message.

#### VMMUserNotificationCenterDelegate (Protocol)
Protocol for `VMMUserNotificationCenter`  delegate.

```objectivec
-(void)actionButtonPressedForNotificationWithUserInfo:(nullable NSObject*)userInfo;
```

If `NSUserNotificationCenter` or `NSAlert` is used, that function is called when the action button is pressed, and the user information is provided.


### VMMMenu
Based in `NSMenu+Dark` (https://github.com/swillits/NSMenu-Dark). 

```objectivec
+ (void)forceLightMenu;
```

Gives every VMMMenu (which is basically a  `NSMenu`) the light color of the Aqua appearance, even during Mojave's dark mode.

```objectivec
+ (void)forceDarkMenu;
```

Gives every VMMMenu (which is basically a  `NSMenu`) the dark color of the Dock right-click menu, even in macOS 10.6.

```objectivec
+ (void)forceSystemMenu;
```

Gives every VMMMenu (which is basically a  `NSMenu`) the regular system color.

### NKFTPManager

Replica of `FTPManager` by `nkreipke` with minor modifications. The original project can be found here:
https://github.com/nkreipke/FTPManager

### VMMLogUtility

```objectivec
NSDebugLog(NSString *format, ...)
```

In Debug, prints a log like `NSLog`, but it doesn't have the `NSLog` prefix, and also prints the log to a `debug.log` file in your Desktop. In Release, does nothing.

```objectivec
NSStackTraceLog()
```

Prints the stacktrace log like in `[NSThread callStackSymbols]`, but using `NSDebugLog`.

```objectivec
measureTime(__message){}
```

Based in `LOOProfiling.h`'s `LOO_MEASURE_TIME` (https://gist.github.com/sfider/3072143). Measure the time that its block takes to run and print it using `NSDebugLog`.

## Workarounds and Hacks
Colors indecate the level of the hack: Green (![#00ff00](https://placehold.it/15/00ff00/000000?text=+)) means it can't be noticed; Blue (![#0000ff](https://placehold.it/15/0000ff/000000?text=+)) means it can only be noticed under certain circunstances, but it does not affect the UX; Yellow (![#ffff00](https://placehold.it/15/ffff00/000000?text=+)) means it can be noticed, and affect the UX, but just a little bit; Red (![#f03c15](https://placehold.it/15/f03c15/000000?text=+)) means it can be noticed AND may affect the UX harshly.

### - ![#00ff00](https://placehold.it/15/00ff00/000000?text=+) [NSData jsonStringWithJsonObject:object] (macOS = 10.6)
The JSON string is created manually since `NSJSONSerialization` was not available before macOS 10.7.

### - ![#00ff00](https://placehold.it/15/00ff00/000000?text=+) [NSData dataWithJsonObject:object] (macOS = 10.6)
The JSON data is created based in the function above, since `NSJSONSerialization` was not available before macOS 10.7.

### - ![#00ff00](https://placehold.it/15/00ff00/000000?text=+) [(NSData*)object jsonObject] (macOS = 10.6)
The JSON object is created using `SZJsonParser` since `NSJSONSerialization` was not available before macOS 10.7. Some changes were make in `SZJsonParser` to support the existence of base64 strings inside the JSON.

### - ![#0000ff](https://placehold.it/15/0000ff/000000?text=+) [(NSImage*)img saveAsIcnsAtPath:path] (macOS = 10.6)
In macOS 10.7+ systems, icns files are created with `iconutil`, using `tiff2icns` only if the first one does not return a valid image. macOS 10.6 systems create using `tiff2icns` only, since `iconutil` was introduced in macOS 10.7. The only consequence of that is that the icons created in macOS 10.6 are going to have only one size, which makes them look a bit bugged if you move them to a macOS 10.12+ computer and show them in Finder with the list view mode.

### - ![#ffff00](https://placehold.it/15/ffff00/000000?text=+) [(NSOpenPanel*)panel setWindowTitle:title] (macOS >= 10.11 )
From macOS 10.11 and on, the `setTitle:` function does nothing to `NSOpenPanel`'s. Considering that, this function uses `setMessage:` for macOS 10.11+ and `setTitle:` for macOS 10.10-.

### - ![#00ff00](https://placehold.it/15/00ff00/000000?text=+) ![#f03c15](https://placehold.it/15/f03c15/000000?text=+) [(VMMUserNotificationCenter*)notificationCenter deliverNotificationWithTitle:title message:message userInfo:info icon:icon actionButtonText:actionButton] (macOS <= 10.7)
Since `NSUserNotification` was only introduced in macOS 10.8, macOS 10.7 and below require a different approach. In those systems, `VMMUserNotificationCenter` uses Growl instead, if it can found. If it don't, it shows a simple `NSAlert` instead of a notification. So you still have notifications in macOS 10.6 and 10.7, but only if you have Growl. Considering that, that function has two ratings.

### - ![#f03c15](https://placehold.it/15/f03c15/000000?text=+) [(NSString*)string componentsMatchingWithRegex:regex] (macOS = 10.6)
This is the dirtiest hack of them all. Since `NSRegularExpression` was introduced in macOS 10.7, the only method that I found to do that (since the `RegexKit` framework do not compile anymore) is using Python. In macOS 10.6 only, that function will create a temporary file with `string` and a temporary python script which should parse `string` and return the components matching with `regex`. It's very slow in comparison to `NSRegularExpression`, and should not be used multiple times in sequence (however, it can be used simultaneously in the latest versions), but at least it works using the same kind of regex of `NSRegularExpression` ... please, forgive me.

I tried using RegexKitLite as well (https://github.com/inquisitiveSoft/RegexKitLite), however it has some weird bugs when you use it multiple times, even after cleaning its cache.


