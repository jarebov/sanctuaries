*********************************************************************************************************************************
*																																*
*			Sanctuaries																											*
*			name file: violent.do																								*
*			diff-in-diff regressions, violent crime - various specifications											 			*
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
sort fips year
merge m:1 fips year using covariates.dta
drop if _m == 2
drop _m

** generate useful variables 
gen quarter = quarter(dofq(time_quarter)) //calendar quarter (1,2,3,4)
gen year_en = year(dofq(quarter_enactment)) //calendar year of enactment
gen hisp_share = hisp_pop / tot_pop
gen black_share = black_pop / tot_pop
global covar = "black_share hisp_share mig_inflow medianho urate"
bysort fips (year): carryforward $covar, replace // fill in missings by just doing carryfw
gsort fips -year
bysort fips: carryforward $covar, replace // fill in missings by just doing carryfw
bysort fips (year): gen tot_pop2000 = tot_pop[1] //baseline population (year 2000)
bysort fips (year): gen black_share2010 = black_share[1] //baseline black share (year 2010)
bysort fips (year): gen hisp_share2010 = hisp_share[1] //baseline hispanic share (year 2010)
bysort fips (year): gen mig_inflow2005 = mig_inflow[1] //baseline migration (year 2005)
bysort fips (year): gen dem2008 = dem_vote_frac[9] //baseline migration (year 2005)
bysort fips time_quarter: gen obsfips = _n //keep track duplicate control counties
gen timefromenact = time_quarter - quarter_enactment
egen quarter_enactment2 = mean(quarter_enactment), by(group) //assign quarter of enactment to control units 
egen year_enactment2 = mean(year_en), by(group) //assign year of enactment to control units 
format quarter_enactment2 %tq
gen timefromenact2 = time_quarter - quarter_enactment2
gen post = timefromenact2 > 0
gen property = cod21_c1_i_rate + cod17_c1_i_rate  + cod23_c1_i_rate
gen violent = cod1_c1_i_rate + cod3_c1_i_rate + cod11_c1_i_rate + cod6_c1_i_rate
gen log_tot = log(codtot_c1_i_rate)
gen log_violent = log(violent)
gen log_property = log(property)

egen group_year = group(group year)
gen treat_post = treat == 1 & post == 1
qui sum hisp_share2010, det
gen hisp_q4 = hisp_share2010 > r(p75)
gen hisp_q3 = hisp_share2010 <= r(p75) & hisp_share2010 > r(p50)
gen hisp_q2 = hisp_share2010 <= r(p50) & hisp_share2010 > r(p25)
gen hisp_q1 = hisp_share2010 <= r(p25)
gen treat_post_hisp1 = treat_post * hisp_q1
gen treat_post_hisp2 = treat_post * hisp_q2
gen treat_post_hisp3 = treat_post * hisp_q3
gen treat_post_hisp4 = treat_post * hisp_q4
gen county = 0
gen trend = 0
gen Gr = 0

keep if year >= 2006 & year_enactment2 <= 2016


*** Winsorize
forvalues y = 2006/2016 {
qui sum codtot_c1_i_rate, det
drop if (codtot_c1_i_rate <= r(p1)) & year == `y'
}

global covar2 = "c.black_share2010#i.year c.hisp_share2010#i.year c.mig_inflow2005#i.year medianho urate"


gen Timeframe = 1 if timefromenact2 >= -8 & timefromenact2 <= 4
bysort group time_quarter: egen timeframe = max(Timeframe)
drop Timeframe

** Labels
label variable treat_post "no-detainer $\times$ post"
label variable treat_post_hisp1 "no-detainer $\times$ post $\times$ q1"
label variable treat_post_hisp2 "no-detainer $\times$ post $\times$ q2"
label variable treat_post_hisp3 "no-detainer $\times$ post $\times$ q3"
label variable treat_post_hisp4 "no-detainer $\times$ post $\times$ q4"


********************************************		Regressions 	******************************************************

* Table 1: simple DD, county FE, county FE with pre-trends, with and without covariates 
eststo t1: qui areg log_violent treat_post i.time_quarter county if timeframe == 1 [aw = tot_pop2000], a(fips) cluster(fips)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)

eststo t2: qui areg log_violent treat_post i.time_quarter $covar2 county if timeframe == 1 [aw = tot_pop2000], a(fips) cluster(fips)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)

preserve
	qui areg log_violent c.year#i.fips treat_post i.time_quarter if post == 0 [aw=tot_pop], a(fips)
	codebook fips if e(sample)
	mat b=e(b)
	mat b=b[1,1..374]
	mat score res1 = b
	gen res2 =  log_violent -  res1
	eststo t3: qui areg res2 treat_post i.time_quarter trend county if timeframe == 1 [aw = tot_pop2000], a(fips) cluster(fips)
	disp _b[treat_post]
	disp _b[treat_post]/_se[treat_post]
	disp e(N)
restore

preserve
	qui areg log_violent c.year#i.fips treat_post i.quarter i.year $covar2 if post == 0 [aw=tot_pop], a(fips)
	codebook fips if e(sample)
	mat b=e(b)
	mat b=b[1,1..367]
	mat score res1 = b
	gen res2 =  log_violent -  res1
	eststo t4: qui areg res2 treat_post i.quarter i.year $covar2 trend county if timeframe == 1 [aw = tot_pop2000], a(fips) rob cluster(fips)
	disp _b[treat_post]
	disp _b[treat_post]/_se[treat_post]
	disp e(N)
restore
esttab	t1 t2 t3 t4 using "$tab/logviolent_dd1.tex"	///
		, b(4) se(4) unstack nonote label replace se keep(treat_post) indicate("County FE = *county*" "Time FE = *year*" "Controls = urate" "Trends = trend") ///
		nomti obslast star(* 0.10 ** 0.05 *** 0.01) width(0.7\textwidth)


* Table 2: group-by-year FE, with pre-trends, with and without covariates 
eststo t1: qui areg log_violent treat_post i.time_quarter i.fips Gr if timeframe == 1 [aw = tot_pop2000], a(group_year) cluster(fips)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)

eststo t2: qui areg log_violent treat_post i.time_quarter i.fips $covar2 Gr if timeframe == 1 [aw = tot_pop2000], a(group_year) cluster(fips)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)

preserve
	qui areg log_violent c.year#i.fips treat_post  i.fips i.time_quarter if post == 0 [aw=tot_pop], a(group_year)
	codebook fips if e(sample)
	mat b=e(b)
	mat b=b[1,1..374]
	mat score res1 = b
	gen res2 =  log_violent -  res1
	eststo t3: qui areg res2 treat_post i.fips i.time_quarter trend Gr if timeframe == 1 [aw = tot_pop2000], a(fips) cluster(group_year)
	disp _b[treat_post]
	disp _b[treat_post]/_se[treat_post]
	disp e(N)
restore

preserve
	qui areg log_violent c.year#i.fips treat_post  i.fips i.quarter i.year $covar2 if post == 0 [aw=tot_pop], a(fips)
	codebook fips if e(sample)
	mat b=e(b)
	mat b=b[1,1..367]
	mat score res1 = b
	gen res2 =  log_violent -  res1
	eststo t4: qui areg res2 treat_post  i.fips i.time_quarter $covar2 Gr trend if timeframe == 1 [aw = tot_pop2000], a(fips) rob cluster(fips)
	disp _b[treat_post]
	disp _b[treat_post]/_se[treat_post]
	disp e(N)
restore
esttab	t1 t2 t3 t4 using "$tab/logviolent_dd2.tex"	///
		, b(4) se(4) unstack nonote label replace se keep(treat_post) indicate("County FE = *fips*" "Group-by-year FE = *Gr*" "Time FE = *year*" "Controls = urate" "Trends = trend") ///
		nomti obslast star(* 0.10 ** 0.05 *** 0.01) width(0.7\textwidth)

		

