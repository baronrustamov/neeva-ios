# Xcode Troubleshooting

## Simulator Not Working Correctly
- From the simulator menu go to `Device > Erase all Content and Settings`
- Clean Xcode build folder `command + shift + k`

#
## Xcode Running Slow
- Delete derived data `Library/Developer/Xcode/DerivedData`
- Delete archive files `Library/Develoepr/Xcode/Archives`
- Restart Xcode & your Mac

#
## Carthage Problems
- Run `./boostrap.sh --force`
- In Xcode `File > Packages > Reset Package Cache`

#
## The Nuclear Option
This fixes most problems with Xcode:
- Run `./bootstrap.sh --force`
- Clean Xcode build folder `command + shift + k`
- In Xcode `File > Packages > Reset Package Cache`

Usually most problems can be fixed with combination of any of the above steps.

#
## Switching Xcode Application
- Go to `Xcode/Preferences/Locations`
- Set Command Line Tools to your preffered version
- Run `./boostrap.sh --force`
- In Xcode `File > Packages > Reset Package Cache`

#
## Build Failed But Errors Aren't Showing
- Open the project navigator
- Show the report navigator (the most trailing button)
- Select the failed build to show the log
- Select `Errors Only`

#
If you run into a problem you can't seem to resolve, reach out for help or [file an issue](https://github.com/neevaco/neeva-ios/issues/new)!