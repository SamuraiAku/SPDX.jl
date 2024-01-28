# CHANGELOG

## New Version
* On further review on the SPDX specification, updated the algorithm for computing a package verification code
* Replaced the function spdxchecksum() with ComputePackageVerificationCode() and ComputeFileChecksum()
* Resolved [#40](https://github.com/SamuraiAku/SPDX.jl/issues/40): Handling of symbolic links when computing the package verification code
* Resolved [#29](https://github.com/SamuraiAku/SPDX.jl/issues/29): Support checksum calculation on a single file
* Resolved [#28](https://github.com/SamuraiAku/SPDX.jl/issues/28): Use the Logging standard library to record all the files processed and their checksums

## v0.3.2
* Add lots of tests to improve Code Coverage

## v0.3.1
* Resolved [#30](https://github.com/SamuraiAku/SPDX.jl/issues/30) and [#32](https://github.com/SamuraiAku/SPDX.jl/issues/32), adding Continuous Integration (CI) workflow and improving the tests.

## v0.3.0
* Resolved [#16](https://github.com/SamuraiAku/SPDX.jl/issues/16), Update SPDX Data Types to use mutable structs with the const keyword in Julia 1.8. This was a substantial rewrite of the module internals that requires a newer version of Julia and justified the minor revision change
* Resolved [#7](https://github.com/SamuraiAku/SPDX.jl/issues/7), Improve loading time
* Resolved [#24](https://github.com/SamuraiAku/SPDX.jl/issues/24), SpdxCreatorV2 puts an empty email field on a Tool creator
* Resolved [#33](https://github.com/SamuraiAku/SPDX.jl/issues/33), Add support for Sub-paths in a Package Download Location


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