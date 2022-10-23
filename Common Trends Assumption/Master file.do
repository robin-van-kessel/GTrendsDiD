*install packages
cap ado uninstall ftools     
cap ado uninstall reghdfe     
cap ado uninstall sumhdfe

net install ftools, from("https://raw.githubusercontent.com/sergiocorreia/ftools/master/src/")
net install reghdfe, from("https://raw.githubusercontent.com/sergiocorreia/reghdfe/master/src/")
net install sumhdfe, from("https://raw.githubusercontent.com/ed-dehaan/sumhdfe/master/src/")
net install rdrobust, from("https://raw.githubusercontent.com/rdpackages/rdrobust/master/stata") replace
ssc install rtfutil
ssc install coefplot, replace
ssc install estout, replace

**Windows
	global data "C:/Users/robin/Dropbox/Google Trends/CTA"
	global results "C:/Users/robin/Dropbox/Google Trends/Output/CTA"
	global root "C:/Users/robin/Dropbox/Google Trends/Scripts/CTA"

*Set Directory	
global root "/Users/robinvankessel/Dropbox/Google Trends/Scripts/CTA"
global data "/Users/robinvankessel/Dropbox/Google Trends/CTA"
global results "/Users/robinvankessel/Dropbox/Google Trends/Output/CTA"

*Import and clean data

do "$root/OnlineDoctor"
do "$root/OnlineHealth"
do "$root/eHealth"
do "$root/Telehealth"
do "$root/Telemedicine"
do "$root/OnlineNurse"
do "$root/OnlinePharmacy"
do "$root/HealthApp"

*Merge Data

do "$root/Merge all countries"

*Analysis

do "$root/Data Analysis"
























