*********************************************************************************************************************************
*																																*
*			Sanctuaries																											*
*			name file: nr_policies.do																							*
*			number of policies over time																			 			*
*																																*
*********************************************************************************************************************************

clear all
set more off
set matsize 11000

global user = 2 // 1 Jaime, 2 Barbara

if $user == 1{
cd "/Users/JAIME/Dropbox/research/sanctuaries/data/output_datasets"
global out = "/Users/JAIME/Dropbox/research/sanctuaries/out"
global tab = "/Users/JAIME/Dropbox/research/sanctuaries/sanctuaries_git/tex/tables"
}

if $user == 2{
cd "~/Dropbox/Research/sanctuaries/data/output_datasets"
global out = "~/Dropbox/Research/sanctuaries/out"
global tab = "~/Dropbox/Research/sanctuaries/sanctuaries_git/tex/tables"
}

clear all
set more off


use offense_panel_group.dta, clear
keep if treat == 1
keep fips quarter_enactment time_quarter treat year
gen treat1 = time_quarter > quarter_en 
collapse (sum) treat1, by(time_quarter year)
drop if year == 2016
tsset time_quarter
gen treat2 = l.treat1
reshape long treat, i(time_quarter) j(n)
gsort time_quarter -n
twoway (line treat time_quarter, lcolor(black) lpattern(thick)) if year > 2007, xtitle("time") ytitle("nr policies")
graph export $out/nr_policies.png, replace
