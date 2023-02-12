# SPDX-License-Identifier: MIT

using SPDX
using Pkg

spdxDoc= SPDX.readspdx("SPDX_jl.spdx.json")
spdxPkgNames= [pkg.Name for pkg in spdxDoc.Packages]

envpkgs= Pkg.dependencies()
SpdxPackageInfo= envpkgs[Pkg.project().dependencies["SPDX"]]

pkgidx= findfirst("SPDX.jl" .== spdxPkgNames)
spdxDoc.Packages[pkgidx].Version= string(SpdxPackageInfo.version)

for (spdxdep, uuid) in SpdxPackageInfo.dependencies
    version= envpkgs[uuid].version
    isnothing(version) && continue # Go to next iteration if it's a standard library
    local pkgidx= findfirst(spdxdep*".jl" .== spdxPkgNames)
    if isnothing(pkgidx)
        println("WARNING: SPDX dependency ", spdxdep, " is not in the SPDX Document. Please add the package and rerun this script")
        continue
    end
    spdxDoc.Packages[pkgidx].Version= string(version)
    spdxDoc.Packages[pkgidx].DownloadLocation= SpdxDownloadLocationV2(spdxDoc.Packages[pkgidx].DownloadLocation; VCS_Tag= "v"*string(version))
end

updatenamespace!(spdxDoc)
setcreationtime!(spdxDoc)

SPDX.writespdx(spdxDoc, "SPDX_jl.spdx.json")