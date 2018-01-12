/* plots and saves a time trend for each sample county (treat and control) in 
 out/visual_trends/ so that we can spot bad data points*/
clear all
set more off

global user = 1 // 1 Jaime, 2 Barbara

if $user == 1{
global path = "/Users/JAIME/Dropbox/research/sanctuaries"
}

if $user == 2{
global path =  "~/Dropbox/Research/sanctuaries"
}

use "$path/data/output_datasets/offense_panel_group.dta", clear
sort group fips time_quarter



* Unique identifier (fips - group)
tostring fips, gen(fips_string)
tostring group, gen (group_string)

gen fips_group = "f"+fips_string+"-"+"g"+group_string

isid fips_group time_quarter


**** TOTAL CRIMES
levelsof fips_group, local(unit)
foreach u of local unit{
	preserve
		keep if fips_group== "`u'"
		keep if inrange(year,2005,2016)
		local time = quarter_enactment2
		
		qui twoway connect codtot_c1_i_rate time_quarter, xline(`time')
		
		qui graph export "$path/out/visual_trends/`u'.pdf", replace

	restore	
}


**** VIOLENT CRIMES
levelsof fips_group, local(unit)
foreach u of local unit{
	preserve
		keep if fips_group== "`u'"
		keep if inrange(year,2005,2016)
		local time = quarter_enactment2
		
		qui twoway connect codviolent_c1_i_rate time_quarter, xline(`time')
		
		qui graph export "$path/out/visual_trends/violent`u'.pdf", replace

	restore	
}



**** NONVIOLENT CRIMES
levelsof fips_group, local(unit)
foreach u of local unit{
	preserve
		keep if fips_group== "`u'"
		keep if inrange(year,2005,2016)
		local time = quarter_enactment2
		
		qui twoway connect codnonviolent_c1_i_rate time_quarter, xline(`time')
		
		qui graph export "$path/out/visual_trends/nonviolent`u'.pdf", replace

	restore	
}







