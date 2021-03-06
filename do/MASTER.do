********************************************************************************
**************** MASTER PROGRAM: Sanctuaries ***********************************
********************************************************************************


************************************************************************
clear all
set more off

global user = 1 // 1 Jaime, 2 Barbara

if $user == 1{
global path = "/Users/JAIME/Dropbox/research"
}

if $user == 2{
global path = "~/Dropbox/Research"// Barbara path
}
************************************************************************



********* Paths ************

global build_do    = "$path/sanctuaries/sanctuaries_git/do/build"
global analysis_do = "$path/sanctuaries/sanctuaries_git/do/analysis"
******************************




*************** BUILD DATA FROM RAW FILES **********************************

*County covariates:
run "$build_do/build_census_county_home_ownership.do"	// county covariates: home ownership rates from 2000, 2010 Censuses
run "$build_do/build_EOP_county_covariates.do" 	// county covariates: Equality of Opportunity Project covariates
run "$build_do/build_leip_vote_pres_elections_bycounty.do"	// county covariates: Presidential Election vote shares 2000-2012
run "$build_do/clean_bls.do"	//county covariates: BLS data on labor force stats for years 2005-2016
run "$build_do/clean_intercensal_pop.do"	//cleans Census Intercensal pop data. Generates total pop, pop in workng age, and pop by race
run "$build_do/clean_landarea_census2010.do"	//cleans land area info from Census 2010
run "$build_do/clean_saipe.do"	//cleans SAIPE (income and poverty) Census for years 2005-2015
******************

*Policies:
run "$build_do/10pct_sample_ICE_counties.do"	//generate a 10 pct random sample of counties from ICE no detainer list in order to lok at their policy changes carefully
run "$build_do/clean_upwork.do"	//cleans data on policies obtained from upwork
run "$build_do/match_icedetainer_countyid.do"// matches raw data from ICE detainer agreement "ICE_no_detainer_policies.xls" w/ county ids
******************


*Crime:
run "$build_do/build_urc_annual.do"	//build an annual county panel dataset with URC crime data from NACJD **OLD**

run "$build_do/clean_ucr_crosswalks.do"	//build UCR crosswalks (to fips codes, and other variables)

run "$build_do/clean_ucr_reta.do" //compile UCR monthly ASR from raw data into Stata raw data version (year by year)
run "$build_do/build_arrests_file.do" // elaborates those yearly raw files and generates a county-month-year file with total arrests

run "$build_do/clean_ucr_asr.do" //compile UCR monthly Return A from raw data into Stata raw data version (year by year)
run "$build_do/build_offense_file.do" // elaborates those yearly raw files and generates a county-month-year file with total offenses


******************



run "$build_do/clean_countyborder.do"	//cleans county_border files

***************** 	MERGE DATA	*********************************
run "$build_do/build_panel_covariates.do" // generates panel of covariates from different sources
run "$build_do/build_treat_control.do"		// generates list of treatment and control using adjacency files and differen treatment definitions
run "$build_do/build_panel_group.do"		// generates QUARTERLY panel of treatment and control which contains treated counties and their bordering ones. control counties appear more than once if they border with more than one treated county.





***************** 	ANALYSIS	*********************************
run "$analysis_do/plot_trends_all_counties.do"			// plots and saves a time trend for each sample county (treat and control) in out/visual_trends/ so that we can spot bad data points
run "$analysis_do/balance_table.do"						// table of sumstats: US, treated, and bordering
run "$analysis_do/county_characteristics_graphs.do"		// histograms of main characteristics: US, treated, and bordering
run "$analysis_do/desc_trends.do"						// descriptive quarterly crime time trends graphs and event study graphs
run "$analysis_do/offenses.do"							// diff-in-diff, all crimes
run "$analysis_do/violent.do"							// diff-in-diff, violent crimes
run "$analysis_do/property.do"							// diff-in-diff, property crimes
run "$analysis_do/offenses_by_hispanic.do"				// diff-in-diff, all/violent/property crimes, by quartile of hispanic pop


