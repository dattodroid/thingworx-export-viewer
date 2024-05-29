# Changelog
All notable changes to this project will be documented in this file.

## [2.3.9] - 2023-01-04
### Changed
- 'ignore comments' option now works with single line (//) and multi lines (/* */) comment

## [2.3.8] - 2022-12-30
### Added
- added 'ignore (single line) comments' option for search in code

## [2.3.7] - 2018-10-05
### Changed
- bug fix
### Added
- new Model Check rule for PSPT-7786 : Local property bindings allow to bind and save different property types (e.g, DATETIME to STRING)

## [2.3.6] - 2018-09-10
### Changed
- highligthed the fact that the `security.fileuri.strict_origin_policy=false` setting is required with recent version of Firefox
https://bugzilla.mozilla.org/show_bug.cgi?id=1500453

## [2.3.5] - 2018-09-26
### Changed
- moved ModelCheck to its own dialog/tab
- basic ModelCheck "engine" that looks in code (regex), XML (xpath) and in memory representation of the model
- major js refactoring

## [2.3.0] - 2018-09-12
### Added
- Class Diagram for entities descendent
- Context menu in code viewer to search definitions and references

## [2.2.0] - 2018-09-12
### Added
- Class Diagram (inheritance) for entities
- html startup page

## [2.1.4] - 2018-09-04
### Fix
- fix subscription names in model dialog

## [2.1.3] - 2018-09-04
### Added
- basic help
### Changed
- sticky header with entity types links

## [2.1.2] - 2018-09-03
### Fix
- fix templates / shapes links

## [2.1.1] - 2018-08-30
### Fix
- fix in code highlighting

## [2.1.0] - 2018-08-30
### Added
- check model for known corruptions (Orphan Bindings without definition)
- show entity details based on inheritance
### Changed
- complete refactoring
