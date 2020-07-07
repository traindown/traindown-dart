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
