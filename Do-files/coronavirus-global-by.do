clear all
set scheme plotplain

tempfile pop
use "https://github.com/partha-deb/COVID-19-outcomes/blob/master/Data/worldpopulation.dta?raw=true"
save `pop'

import delimited using "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv", clear

rename v4 lon

reshape long v, i(countryregion provincestate) j(dt)
rename v deaths
rename countryregion country

gen date = date("1/22/2020","MDY") + dt-5
format date %td

collapse (sum) deaths, by(country date)

keep if inlist(country,"US","France","Sweden","Norway","Denmark","United Kingdom","Germany","Italy","Spain")
merge m:1 country using `pop'
drop if _merge==2
drop _merge

gen deathspc = deaths / pop * 1000

local ll 1
local maxdays 30

bysort country(date): gen t0 = (deathspc>`ll')
keep if t0==1

bysort country(date): gen days = _n

twoway scatter deathspc days if days<`maxdays', by(country, note("")) ///
	subtitle(, bcolor(gs15%50)) mcolor(teal) msize(*.5) ///
	ytitle("cumulative deaths per million people") ///
	xtitle("days since `ll'/million deaths") ///
	name(countries, replace)

exit
