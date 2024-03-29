## 3.2.1
- [FIX] Handle whitespace in date/time Strings better.

## 3.2.0
- Add Importer class to help sync devices.

## 3.1.0
- Deprecated all IO operations.
- Please refer to the tests to see examples on manually performing IO.


## 3.0.0
- **BREAKING** Relocated all IO operations on Session and Inspector to SessionIO.
- Migrate Session.from_file to SessionIO.sessionFromFile.
- Migrate Session.from_path to SessionIO.sessionFromPath.
- Migrate Inspector.from_files to SessionIO.inspectorFromFiles.
- Migrate Inspector.from_directory to SessionIO.inspectorFromDirectory.
- Update docs.

## 2.5.0
- Refactor to support Null Safety.

## 2.4.1
- Fixed handling of formatting on multi session files.

## 2.4.0
- Added #export to Inspector for easy dumping and sharing of datasets.

## 2.3.1
- Made sure to export Inspector...

## 2.3.0
- Added Inspector: A tool for inspecting a collection of Sessions.
- Bumped min SDK to 2.2.0 to support Set literal usage.

## 2.2.1
- Cleaned out unneccessary internals.
- Deprecated Performance.wasTouched.
- Added stress test for Session.

## 2.2.0
- Added the concept of unit officially to both Session and Movement.
- Altered the underlying logic for the unit API on Performance.
- **NOTE** Special meta constants now live in Metadata (where they should).

## 2.1.6
- Added basic docs for most things

## 2.1.5
- Clean up of files per pub.dev

## 2.1.4
- Fix for incorrect unit attribution on multimovement sessions

## 2.1.3
- Fix for lexer looping when colons were missing on incomplete data

## 2.1.2
- Fix for poor handling of line terminators on various OSes

## 2.1.1
Fixes for:
- Faulty bodyweight handling
- Grace in handling dates (still needs work)
- Correct performance attribution

## 2.1.0
- Refactor Presenters to work with new interals
- Update the example.dart to reflect current usage

## 2.0.1
- Fix incorrect exports

## 2.0.0
- Upgrade to language spec version 1.2.1

## 1.8.0

- Removed auto colon insertion in order to support numbers in names and notes.
- Added ability to use numbers in names and notes. "Preacher 21s" is now valid, folks.
- Fixed additional leading whitespace on supersetted movement names.

## 1.7.0

- Add special amounts that simplify the bodyweight entry. Now, instead of having to manually set a unit you can just say `bw 10r` and it will produce a Performance with a load of 1 and an unit of "bodyweight".
- Some pedantic linter cleanup.

## 1.6.0

- Add metadata chaining. Now you can just slam all your metadata into one line.
- Add support for Movement unit to propagate down into all Performances. Performance unit takes priority over Movement and Movement takes priority over Session.
- Add automatic colon insertion on Movement name.

## 1.5.0

- Add wasTouched to Performance to aid in parsing
- Correct volume calculation for Performance
- Specs for Performance

## 1.4.8

- Add getters for volume on Performance and Movement

## 1.4.7

- Fix for missing performance when switching movements.

## 1.4.6

- Expose all classes for maximum play.

## 1.4.5

- Fix for superfluous linebreak that would occur between Performances during formatting.

## 1.4.4

- Fix for movements that followed performance or performance metadata/notes.

## 1.4.3

- Fix for superset formatting and parsing.

## 1.4.2

- Improved the output of the Formatter based on real world testing.

## 1.4.1

- Remove dependency on dart:mirrors for much GUI in exchange for ugly code.

## 1.4.0

- Holy crap! We now have metadata and notes per each entity: session, movement, and performance.
- This is the final piece for a complete language spec.
- Complete test coverage for all libraries involved in this effort.

## 1.3.1

- Added complete test coverage for EventedParser
- Minor back compat changes to EventedParser

## 1.3.0

- Added EventedParser. This is a much easier abstraction to deal with day to day.
- Moved Formatter and Parser onto EventedParser for much win.
- Updated tests.

## 1.2.1

- Improved Formatter

## 1.2.0

- Removed the CLI pieces to simplify distribution

## 1.1.1

- Add missing export for Formatter

## 1.1.0

- Added Formatter
- Cleaned up examples and provided some comments
- Added dash token

## 1.0.1

- Fix for invalid export
- Added Changelog (yay!)

## 1.0.0

- MVP complete
