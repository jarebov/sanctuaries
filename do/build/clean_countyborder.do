*********************************************************************************************************************************
*																																*
*						Sanctuaries																								*
*						name file: clean_countyborder.do																		*
*						cleans county_border files																				*
*																																*
*********************************************************************************************************************************

clear all
set more off

cd "~/Dropbox/Research/sanctuaries/data"


insheet using "Census/county_adjacency.txt", clear 

carryforward v1 v2, replace
rename v1 name
rename v2 fips
rename v3 adj_name
rename v4 adj_fips
bysort fips: gen n = _n
reshape wide adj_name adj_fips, i(fips) j(n)
order fips name, first
sort fips
save "output_datasets/county_adjacency.dta", replace
