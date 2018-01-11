*********************************************************************************************************************************
*																																*
*			Sanctuaries																											*
*			name file: offenses.do																								*
*			diff-in-diff regressions, total crime - various specifications											 			*
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
gen hisp_share = hisp_pop / tot_pop
gen black_share = black_pop / tot_pop
global covar = "black_share hisp_share mig_inflow medianho urate"
bysort fips (year): carryforward $covar, replace // fill in missings by just doing carryfw
gsort fips -year
bysort fips: carryforward $covar, replace // fill in missings by just doing carryfw
bysort fips (year): gen black_share2010 = black_share[1] //baseline black share (year 2010)
bysort fips (year): gen hisp_share2010 = hisp_share[1] //baseline hispanic share (year 2010)
bysort fips (year): gen mig_inflow2005 = mig_inflow[1] //baseline migration (year 2005)
bysort fips (year): gen dem2008 = dem_vote_frac[9] //baseline migration (year 2005)


egen group_year = group(group time_quarter)
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


global covar2 = "c.black_share2010#i.time_quarter c.hisp_share2010#i.time_quarter c.mig_inflow2005#i.time_quarter medianho urate"


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

* Murder
eststo t1: qui areg lcod1_c1_i_rate_w_dt treat_post i.time_quarter i.fips $covar2 Gr trend if timeframe == 1 [aw = tot_pop2000], a(group_year) cluster(fips)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)

* Rape
eststo t2: qui areg lcod3_c1_i_rate_w_dt treat_post i.time_quarter i.fips $covar2 Gr trend if timeframe == 1 [aw = tot_pop2000], a(group_year) cluster(fips)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)

* Robbery
eststo t3: qui areg lcod6_c1_i_rate_w_dt treat_post i.time_quarter i.fips $covar2 Gr trend if timeframe == 1 [aw = tot_pop2000], a(group_year) cluster(fips)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)

* Assault
eststo t4: qui areg lcod11_c1_i_rate_w_dt treat_post i.time_quarter i.fips $covar2 Gr trend if timeframe == 1 [aw = tot_pop2000], a(group_year) cluster(fips)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)

* Burglary
eststo t5: qui areg lcod17_c1_i_rate_w_dt treat_post i.time_quarter i.fips $covar2 Gr trend if timeframe == 1 [aw = tot_pop2000], a(group_year) cluster(fips)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)

* Larceny
eststo t6: qui areg lcod21_c1_i_rate_w_dt treat_post i.time_quarter i.fips $covar2 Gr trend if timeframe == 1 [aw = tot_pop2000], a(group_year) cluster(fips)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)

* Auto theft
eststo t7: qui areg lcod23_c1_i_rate_w_dt treat_post i.time_quarter i.fips $covar2 Gr trend if timeframe == 1 [aw = tot_pop2000], a(group_year) cluster(fips)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)


esttab	t1 t2 t3 t4 t5 t6 t7 using "$tab/logcrime_bytype.tex"	///
		, b(4) se(4) unstack nonote label replace se keep(treat_post) indicate("County FE = *fips*" "Group-by-time FE = *Gr*" "Time FE = *time*" "Controls = urate" "Trends = trend") ///
		mgroups("Murder" "Rape" "Robbery" "Assault" "Burglary" "Larceny" "Auto Theft", pattern(1 1 1 1 1 1 1 ) prefix(\multicolumn{@span}{c}{) suffix(}) ///
		span erepeat(\cmidrule(lr){@span})) nomti obslast star(* 0.10 ** 0.05 *** 0.01) 

		

