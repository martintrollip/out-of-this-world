# Out of this World 

This is an iOS application displaying a list of planets with functionality to zoom and pan images thereof. It  also retrieves and displays detailed information for each planet in an ordered fashion. The user can also manually add newly discovered planets. It will be saved in `NSUserDefaults`.  

## Getting started
In order to get a copy of this project clone it or download the zip file

```
git clone
```

This may be opened with XCode. 

### Prerequisities 
X Code and iOS development environment.

### Installing
Open the project in XCode `project.pbxproj` and build.  This can be executed on a emulator or Apple device.

## Examples

`NSUserDefaults` for data persistence
``` 
//Update user defaults with key #define ADDED_SPACE_OBJECTS_KEY @"Added space objects"
[[NSUserDefaults standarduserDefaults] setObject:obj forKey:ADDED_SPACE_OBJECTS_KEY]];
[[NSUserDefaults standarduserDefaults] synchronize];
```

## Authors
* **Martin Trollip** - *Learning to code in iOS from Bitfountain* - [martintrollip](https://github.com/martintrollip)

## Acknowledgements
Thanks to [Bitfountain](https://www.bitfountain.io) and [Eliot Arnts](https://github.com/arntzel) for providing me with the required knowledge and resources in order to complete this project and broaden my programming horizons. 
