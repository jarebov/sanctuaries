*********************************************************************************************************************************
*																																*
*						Sanctuaries																								*
*						name file: clean_landarea_census2010.do																	*
*						cleans land area info from Census 2010																	*
*																																*
*********************************************************************************************************************************

clear all
set more off

cd "~/Dropbox/Research/sanctuaries/data"


insheet using "Census/landarea_census2010.csv", clear 

keep gct_stubtargetgeoid2 hd02 subhd0301 subhd0302 subhd0303
rename gct_stubtargetgeoid2 fips
rename hd02 housing_units
rename subhd0301 total_area
rename subhd0302 water_area
rename subhd0303 land_area

label variable fips				"FIPS code"
label variable total_area		"Total area (sq. miles)"
label variable water_area		"Water code (sq. miles)"
label variable land_area		"Land code (sq. miles)"

gen x = fips / 1000
drop if x < 1 | fips == 0
drop x
sort fips
save output_datasets/landarea.dta, replace
