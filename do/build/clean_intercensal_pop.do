*********************************************************************************************************************************
*																																*
*						Sanctuaries																								*
*						name file: clean_intercensal_pop.do																		*
*						cleans Census Intercensal pop data. Generates total pop, pop in workng age, and pop by race				*
*																																*
*********************************************************************************************************************************

clear all
set more off

cd "~/Dropbox/Research/sanctuaries/data"




*** 2010-2016

insheet using "Census/intercensal_pop/2010_2016/cc-est2016-alldata.csv", clear

* Keep Census counts for 2010 (year == 1), and estimates for 2011-2016 (years 4-9)
keep if year == 1 | year >= 4
replace year = 2010 if year == 1
replace year = year + 2007 if year < 10

gen fips = string(state,"%02.0f") + string(county,"%03.0f")
destring fips, replace
drop sumlev state county stname ctyname

* total population
preserve
keep if agegrp == 0
collapse (sum) tot_pop, by(fips year)
label variable tot_pop "Total population count"
sort fips year
save "output_datasets/population_2010_2016.dta", replace
restore

* total population in working age
preserve
keep if agegrp >= 4 & agegrp <= 13
collapse (sum) workingage_pop = tot_pop, by(fips year)
label variable workingage_pop "Population in working age"
sort fips year
save "output_datasets/wkage_pop.dta", replace
restore

* total population by race
preserve
keep if agegrp == 0
collapse (sum) wa_male wa_female ba_male ba_female aa_male aa_female h_male h_female, by(fips year)
gen white_pop = wa_male + wa_female
gen black_pop = ba_male + ba_female
gen asian_pop = aa_male + aa_female
gen hisp_pop = 	h_male + h_female
label variable white_pop 	"White population"
label variable black_pop 	"Black population"
label variable asian_pop 	"Asian population"
label variable hisp_pop 	"Hispanic population"
sort fips year
save "output_datasets/pop_byrace.dta", replace
restore

** 2000-2010

insheet using "Census/intercensal_pop/2000_2010/co-est00int-tot.csv", clear
drop if county == 0
gen fips = string(state,"%02.0f") + string(county,"%03.0f")
destring fips, replace
drop sumlev region division state county stname ctyname
drop estimatesbase2000 popestimate2010 census2010pop
reshape long popestimate, i(fips) j(year)
keep if year >= 2005
rename popestimate tot_pop
append using "output_datasets/population_2010_2016.dta"
label variable tot_pop "Total population count"
sort fips year
save "output_datasets/population.dta", replace
rm "output_datasets/population_2010_2016.dta"
