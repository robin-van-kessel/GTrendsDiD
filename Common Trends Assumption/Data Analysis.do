**Windows
	global data "C:/Users/robin/Dropbox/Google Trends/CTA"
	global results "C:/Users/robin/Dropbox/Google Trends/Output/CTA"
	global root "C:/Users/robin/Dropbox/Google Trends/Scripts"

	ssc inst _gwtmean
	ssc inst coefplot
**Main Analysis

*Figure 1. Google Trends of English keywords
local varlist "OnlineDoctor OnlineHealth Telehealth Telemedicine HealthApp"
foreach var of local varlist {
		use "$data/Google-trends-`var'-data/daily_`var'_19_21_all_full.dta", clear
		drop if pandemic_duration==0 
		drop if pandemic_duration<-60
		keep if pandemic_duration!=.
		
		bysort year pandemic_duration: egen m_`var'_19_21=wtmean(d_`var'_19_21), weight(pop_size)
		
		twoway (connected m_`var'_19_21 pandemic_duration if year==2016, msize(vsmall) lcolor(gs10) mcolor(gs10)) (connected m_`var'_19_21 pandemic_duration if year==2017, msize(vsmall) /*lcolor(black) mcolor(black)*/) (connected m_`var'_19_21 pandemic_duration if year==2018, msize(vsmall) /*lcolor(black) mcolor(black)*/), ///
		xline(0, lpattern(solid) lcolor(cranberry)) legend(order(1 "2016" 2 "2017" 3 "2018")) /*ylabel(0(50)100)*/ ///
		ytitle("`var'") xlabel(-28 -14 0 14 28 42 56 70 84 98 112 126 140) xscale(range(-35 140)) ///
		saving("$results/`var'/`var'_DID.gph", replace) 	
}

graph combine "$results/OnlineDoctor/OnlineDoctor_DID.gph"  "$results/OnlineHealth/OnlineHealth_DID.gph" "$results/Telehealth/Telehealth_DID.gph" "$results/Telemedicine/Telemedicine_DID.gph" "$results/OnlinePharmacy/HealthApp_DID.gph", rows(2) cols(3) imargin(0 0 0 0 0 0 0) iscale(.6) 
graph export "$results/Tables and Figures/GoogleTrends_A4 CTA.pdf", replace

*Change in digital health-related searches since the start of the pandemic (DiD) 2016-2017
local varlist "OnlineDoctor OnlineHealth Telehealth Telemedicine HealthApp"

foreach var of local varlist {
	
	use "$data/Google-trends-`var'-data/daily_`var'_19_21_all_full.dta", clear
		drop if pandemic_duration==0
		keep if pandemic_duration!=.
		keep if year!=2018
		
		replace year=year-2016
		gen pandemic_year=pandemic_period*year 
		/*TLN: values of 2019 are all 0 because they multiply by 0; hence baseline*/

		reghdfe normalised_`var'_19_21 pandemic_year pandemic_duration [pw=pop_size], ///
		absorb(country year week day_w) vce(cluster day)
		eststo DID_`var'
		estadd local countryFE "Yes", replace
		estadd local timeFE "Yes", replace
}

coefplot (DID_OnlineDoctor, keep(pandemic_year) color(cranberry) asequation(OnlineDoctor) ciopts(lcolor(cranberry) recast(rcap)))  ///
	(DID_OnlineHealth, keep(pandemic_year) color(cranberry) asequation(OnlineHealth) ciopts(lcolor(cranberry) recast(rcap))) ///
	(DID_Telehealth, keep(pandemic_year) color(cranberry) asequation(Telehealth) ciopts(lcolor(cranberry) recast(rcap))) ///
	(DID_Telemedicine, keep(pandemic_year) color(cranberry) asequation(Telemedicine) ciopts(lcolor(cranberry) recast(rcap))) ///
	(DID_HealthApp, keep(pandemic_year) color(cranberry) asequation(HealthApp) ciopts(lcolor(cranberry) recast(rcap))) ///
		,label asequation swapnames xline(0, lcolor(black)) recast(bar) ci(95) legend(off) xtitle("DID Estimates")
		graph export "$results/Tables and Figures/DID_Estimates 2016-2017.pdf", replace

*Change in digital health-related searches since the start of the pandemic (DiD) 2017-2018
local varlist "OnlineDoctor OnlineHealth Telehealth Telemedicine HealthApp"

foreach var of local varlist {
	
	use "$data/Google-trends-`var'-data/daily_`var'_19_21_all_full.dta", clear
		drop if pandemic_duration==0
		keep if pandemic_duration!=.
		keep if year!=2016
		
		replace year=year-2017
		gen pandemic_year=pandemic_period*year 
		/*TLN: values of 2020 are all 0 because they multiply by 0; hence baseline*/

		reghdfe normalised_`var'_19_21 pandemic_year pandemic_duration [pw=pop_size], ///
		absorb(country year week day_w) vce(cluster day)
		eststo DID_`var'
		estadd local countryFE "Yes", replace
		estadd local timeFE "Yes", replace
}

coefplot (DID_OnlineDoctor, keep(pandemic_year) color(cranberry) asequation(OnlineDoctor) ciopts(lcolor(cranberry) recast(rcap)))  ///
	(DID_OnlineHealth, keep(pandemic_year) color(cranberry) asequation(OnlineHealth) ciopts(lcolor(cranberry) recast(rcap))) ///
	(DID_Telehealth, keep(pandemic_year) color(cranberry) asequation(Telehealth) ciopts(lcolor(cranberry) recast(rcap))) ///
	(DID_Telemedicine, keep(pandemic_year) color(cranberry) asequation(Telemedicine) ciopts(lcolor(cranberry) recast(rcap))) ///
	(DID_HealthApp, keep(pandemic_year) color(cranberry) asequation(HealthApp) ciopts(lcolor(cranberry) recast(rcap))) ///
		,label asequation swapnames xline(0, lcolor(black)) recast(bar) ci(95) legend(off) xtitle("DID Estimates") 
		graph export "$results/Tables and Figures/DID_Estimates 2017-2018.pdf", replace

