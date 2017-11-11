*********************************************************************************************************************************
*																																*
*						Sanctuaries																								*
*						name file: map_upwork.do																				*
*						builds maps with al policies, using upwork data															*
*																																*
*********************************************************************************************************************************

clear all
set more off

global user = 2 // 1 Jaime, 2 Barbara

if $user == 1{
cd "/Users/JAIME/Dropbox/research/sanctuaries/data/output_datasets"
global out = "/Users/JAIME/Dropbox/research/sanctuaries/out"
}

if $user == 2{
cd "~/Dropbox/Research/sanctuaries/data/output_datasets"
global out = "~/Dropbox/Research/sanctuaries/out"
}

clear all
set more off

****
use "upwork_policies.dta", clear
destring fips, replace

** total policies
preserve
rename fips county
collapse ilrctot, by(county)
maptile ilrctot, geo(county2010) conus stateoutline(thin) // twopt(legend(off))
graph export "$out/map_total_upwork.png", replace
restore
