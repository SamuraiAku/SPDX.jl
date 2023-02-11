SPDX v0.2 Release Notes
=======================

New features
---------------

* Support v2.3 of the SPDX spec (#17)
* Download location is now an object (SpdxDownloadLocationV2) that parses the fields of the URL instead of just a string (#14)
* Make Package Originator and Supplier an SpdxCreatorV2 object instead of a string. (#13)

Bug fixes
----------------
* Strip leading and trailing whitespace when reading JSON and TagValue Files (#15)