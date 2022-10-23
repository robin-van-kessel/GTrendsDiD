	ssc inst _gwtmean
	ssc inst coefplot
**Main Analysis

*Figure 1. Google Trends of keywords (DiD)
local varlist "OnlineDoctor OnlineHealth Telehealth Telemedicine HealthApp"
foreach var of local varlist {
		use "$data/Google-trends-`var'-data/daily_`var'_19_21_all_full.dta", clear
		drop if pandemic_duration==0 
		drop if pandemic_duration<-60
		keep if pandemic_duration!=.
		
		bysort year pandemic_duration: egen m_`var'_19_21=wtmean(normalised_`var'_19_21), weight(pop_size)
		
		twoway (connected m_`var'_19_21 pandemic_duration if year==2019, msize(vsmall) lcolor(gs10) mcolor(gs10)) (connected m_`var'_19_21 pandemic_duration if year==2020, msize(vsmall) /*lcolor(black) mcolor(black)*/), ///
		xline(0, lpattern(solid) lcolor(cranberry)) legend(order(1 "2019" 2 "2020")) /*ylabel(0(50)100)*/ ///
		ytitle("`var'") xlabel(-28 -14 0 14 28 42 56 70 84 98 112 126 140) xscale(range(-35 140)) ///
		saving("$results/`var'/`var'_DID.gph", replace) 	
}

graph combine "$results/OnlineDoctor/OnlineDoctor_DID.gph"  "$results/OnlineHealth/OnlineHealth_DID.gph" "$results/Telehealth/Telehealth_DID.gph" "$results/Telemedicine/Telemedicine_DID.gph" "$results/HealthApp/HealthApp_DID.gph", rows(3) cols(2) imargin(0 0 0 0 0 0 0) iscale(.6) 
graph export "$results/Tables and Figures/GoogleTrends_A4 DiD raw.pdf", replace

*Figure 1A. Google Trends of keywords (DiD) per country
local varlist "OnlineDoctor OnlineHealth Telehealth Telemedicine HealthApp"
foreach var of local varlist {
	forvalues i = 1/6 {
		use "$data/Google-trends-`var'-data/daily_`var'_19_21_all_full.dta", clear
		drop if pandemic_duration==0 
		drop if pandemic_duration<-60
		keep if pandemic_duration!=.
		keep if country==`i'
		
		bysort year pandemic_duration: egen m_`var'_19_21=wtmean(normalised_`var'_19_21), weight(pop_size)
		
		twoway (connected m_`var'_19_21 pandemic_duration if year==2019, msize(vsmall) lcolor(gs10) mcolor(gs10)) (connected m_`var'_19_21 pandemic_duration if year==2020, msize(vsmall) /*lcolor(black) mcolor(black)*/), ///
		xline(0, lpattern(solid) lcolor(cranberry)) legend(order(1 "2019" 2 "2020")) /*ylabel(0(50)100)*/ ///
		ytitle("`var'") xlabel(-28 -14 0 14 28 42 56 70 84 98 112 126 140) xscale(range(-35 140)) ///
		saving("$results/`var'/`var'_DID_`i'.gph", replace) 	
	}
}

forvalues i = 1/6{
graph combine "$results/OnlineDoctor/OnlineDoctor_DID_`i'.gph"  "$results/OnlineHealth/OnlineHealth_DID_`i'.gph" "$results/Telehealth/Telehealth_DID_`i'.gph" "$results/Telemedicine/Telemedicine_DID_`i'.gph" "$results/HealthApp/HealthApp_DID_`i'.gph", rows(3) cols(2) imargin(0 0 0 0 0 0 0) iscale(.6) 
graph export "$results/Tables and Figures/GoogleTrends_A4 DiD_`i'.pdf", replace
}

*Figure 2 + eTable 1. Change in digital health-related searches since the start of the pandemic (DiD) 2019-2020
local varlist "OnlineDoctor OnlineHealth Telehealth Telemedicine HealthApp"

foreach var of local varlist {
	
	use "$data/Google-trends-`var'-data/daily_`var'_19_21_all_full.dta", clear
		drop if pandemic_duration==0
		keep if pandemic_duration!=.
		keep if year!=2021
		
		replace year=year-2019
		gen pandemic_year=pandemic_period*year 
		/*TLN: values of 2019 are all 0 because they multiply by 0; hence baseline*/

		reghdfe normalised_`var'_19_21 pandemic_year pandemic_duration daily_cases_ma daily_deaths_ma [pw=pop_size], ///
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
		,label asequation swapnames xline(0, lcolor(black)) ci(95) legend(off) xtitle("DID Estimates")
		graph export "$results/Tables and Figures/DID_Estimates 2019-2020.pdf", replace


*Figure 3 + eTable 2. Country-specific DiD findings 2019-2020
local varlist "OnlineDoctor OnlineHealth Telehealth Telemedicine HealthApp"

foreach var of local varlist {
	forvalues i=1/6 {
		
	use "$data/Google-trends-`var'-data/daily_`var'_19_21_all_full.dta", clear
		drop if pandemic_duration==0
		keep if pandemic_duration!=.
		keep if year!=2021
		keep if country == `i'
		replace normalised_`var'_19_21 =. if normalised_`var'_19_21 == 0
		
		replace year=year-2019
		gen pandemic_year=pandemic_period*year 
		/*TLN: values of 2019 are all 0 because they multiply by 0; hence baseline*/

		reghdfe normalised_`var'_19_21 pandemic_year pandemic_duration daily_cases_ma daily_deaths_ma, ///
		absorb(year week day_w) vce(cluster day)
		eststo DID_`var'_`i'
		estadd local timeFE "Yes", replace
	}
}			

forvalues i=1/6 {
	coefplot (DID_OnlineDoctor_`i', keep(pandemic_year) color(cranberry) asequation(OnlineDoctor) ciopts(lcolor(cranberry) recast(rcap)))  ///
	(DID_OnlineHealth_`i', keep(pandemic_year) color(cranberry) asequation(OnlineHealth) ciopts(lcolor(cranberry) recast(rcap))) ///
	(DID_Telehealth_`i', keep(pandemic_year) color(cranberry) asequation(Telehealth) ciopts(lcolor(cranberry) recast(rcap))) ///
	(DID_Telemedicine_`i', keep(pandemic_year) color(cranberry) asequation(Telemedicine) ciopts(lcolor(cranberry) recast(rcap))) ///
	(DID_HealthApp_`i', keep(pandemic_year) color(cranberry) asequation(HealthApp) ciopts(lcolor(cranberry) recast(rcap))) ///
		,label asequation swapnames xline(0, lcolor(black)) ci(95) legend(off) xtitle("DID Estimates")
		graph export "$results/Tables and Figures/DID_Estimates_`i' 2019-2020.pdf", replace

}

*Supplementary Table 1. Country-specific DiD findings
local varlist "OnlineDoctor OnlineHealth Telehealth Telemedicine HealthApp"

foreach var of local varlist {
	forvalues i=1/6 {
		
	use "$data/Google-trends-`var'-data/daily_`var'_19_21_all_full.dta", clear
		drop if pandemic_duration==0
		keep if pandemic_duration!=.
		keep if year!=2021
		keep if country == `i'
		
		replace year=year-2019
		gen pandemic_year=pandemic_period*year 
		/*TLN: values of 2019 are all 0 because they multiply by 0; hence baseline*/

		reghdfe normalised_`var'_19_21 pandemic_year pandemic_duration daily_cases_ma daily_deaths_ma, ///
		absorb(year week day_w) vce(cluster day)
		eststo DID_`var'
		estadd local timeFE "Yes", replace
	}
}
