*********************************************************************************************************************************
*																																*
*						Sanctuaries																								*
*						name file: build_panel_covariates.do																	*
*						builds panel of covariates for balance tables															*
*																																*
*********************************************************************************************************************************

clear all
set more off

global user = 2 // 1 Jaime, 2 Barbara

if $user == 1{
cd "/Users/JAIME/Dropbox/research/sanctuaries/data/output_datasets"
}

if $user == 2{
cd "~/Dropbox/Research/sanctuaries/data/output_datasets"
}

clear all
set more off

**

use bls.dta, clear
sort fips year
merge m:1 fips using EOP_county_covariates.dta
drop _m
sort fips year
merge 1:1 fips year using home_ownership_bycounty_2000_2010.dta
drop _m
merge m:1 fips using landarea.dta
drop _m
merge 1:1 fips year using population.dta
drop _m
merge 1:1 fips year using saipe.dta
drop _m
merge 1:1 fips year using wkage_pop.dta
drop _m
merge 1:1 fips year using pres_election_bycounty.dta
drop _m

sort fips year
save covariates.dta, replace




