# SPDX-License-Identifier: MIT

using PkgToSBOM
using SPDX
using Pkg
using UUIDs

spdxFileName= "SPDX.spdx.json"
myName= SpdxCreatorV2("Person", "Simon Avery", "savery@ieee.org")
myTool= SpdxCreatorV2("Tool", "PkgToSBOM.jl", "")
myLicense= SpdxLicenseExpressionV2("MIT")

myPackage_instr= spdxPackageInstructions(
              spdxfile_toexclude= [spdxFileName],
              originator= myName,
              declaredLicense= myLicense,
              copyright= "Copyright (c) 2022 Simon Avery <savery@ieee.org> and contributors",
              name= "SPDX")

devRoot= filter(p-> p.first == "SPDX", Pkg.project().dependencies)
myNamespace= "https://github.com/SamuraiAku/SPDX.jl/blob/main/SPDX.spdx.json"

active_pkgs= Pkg.project().dependencies;
SPDX_docCreation= spdxCreationData(
              Name= "SPDX.jl Developer SBOM",
              Creators= [myName, myTool],
              NamespaceURL= myNamespace,
              rootpackages= devRoot,
              packageInstructions= Dict{UUID, spdxPackageInstructions}(active_pkgs[myPackage_instr.name] => myPackage_instr)
            )

sbom= generateSPDX(SPDX_docCreation)
writespdx(sbom, spdxFileName)