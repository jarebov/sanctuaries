/*generate a 10 pct random sample of counties from ICE no detainer list in 
order to lok at their policy changes carefully
*/

use "/Users/JAIME/Dropbox/research/sanctuaries/data/output_datasets/county_detainer.dta", clear


preserve
keep if detainer==1

* Choose
local s = 31544	// people watching Puigdemont speech 10/10 10:31am PST
local x = 10		// percent of the sample to keep
*

local N = _N

set seed `s'
gen rnd = uniform()
sort rnd
gen rnd_n = _n

keep if rnd_n <= (`x'/100)*`N'

drop rnd rnd_n

*tab county_name

list state fips county_name



restore
