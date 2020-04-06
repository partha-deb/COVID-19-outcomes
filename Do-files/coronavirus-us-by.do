clear all
set scheme plotplain

tempfile pop
import delimited using "https://raw.githubusercontent.com/partha-deb/COVID-19-outcomes/Data/statepopulation.csv"
save `pop'

import delimited using "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_US.csv", clear

rename admin2 county
rename province_state state

reshape long v, i(state county) j(dt)
rename v deaths

gen date = date("1/22/2020","MDY") + dt-13
format date %td

collapse (sum) deaths, by(state date)

keep if inlist(state,"New York","Florida","Washington","California","Michigan","Louisiana","New Jersey","Maryland","Connecticut")

merge m:1 state using `pop'
drop if _merge==2
drop _merge

gen deathspc = deaths / pop * 1000000

local ll 1
local maxdays 30

bysort state(date): gen t0 = (deathspc>`ll')
keep if t0==1

bysort state(date): gen days = _n

twoway scatter deathspc days if days<`maxdays', by(state, note("")) ///
	subtitle(, bcolor(gs15%50)) mcolor(teal) msize(*.5) ///
	ytitle("cumulative deaths per million people") ///
	xtitle("days since `ll'/million deaths") ///
	name(state, replace)

exit
