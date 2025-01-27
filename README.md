# screenshot-auto-renamer
Renames your screenshot filenames as more descriptive




## Compile and run the Swift application


Compile with a package:

```
swift build -c release
```


Run the application:

```
.build/release/screenshot-auto-renamer
```


## errors


```
main.swift:7:19: warning: immutable value 'screen' was never used; consider replacing with '_' or removing it
 5 |     
 6 |     func captureScreen() {
 7 |         guard let screen = NSScreen.main,
   |                   `- warning: immutable value 'screen' was never used; consider replacing with '_' or removing it
 8 |               let cgImage = CGDisplayCreateImage(CGMainDisplayID()) else {
 9 |             print("Could not capture screen")
```


```
'main' attribute cannot be used in a module that contains top-level code
```


### Desired solution

```
How do I use ScreenCaptureKit and SCScreenshotManager swift framework/class on my MacBook pro to detect when i do a screenshot with keyboard commands: "Command + Shift +3", "Command + Shift + 4" or others, to name/rename the screenshot files from "Screenshot 2025-01-25 at 7.42.11 PM.png" to "Safari-Sat-Jan-25-2025-at-7.44.51pm.png".
```





