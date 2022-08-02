* Project: Summer Paper
* Written by: Camila Ayala (mc.ayala94@gmail.com)
* Purpose: This do file cleans council data


* Set directory 
	cd "/Users/camila/Dropbox/PhD/Second year/Summer paper"
	
use "Data/Elecciones/2011/Concejo_2011_Corregida.dta", clear

* Keep people who won a seat
	keep if seats == 1
	rename (first_lastname second_lastname) (apellido1 apellido2)
	br muni_code apellido1 apellido2
	
* Reshape	
	bys muni_code: gen count = _n
	reshape long apellido, i(muni_code count) j(no_apellido)
	
* Drop duplicates in apellido
	drop if mi(apellido)
	duplicates drop muni_code apellido, force
	sort muni_code apellido
	isid muni_code apellido
	
* Extend data for all years
	replace year = 2012
	expand 2, gen(dupindicator)
	replace year = 2013 if dupindicator == 1
	drop dupindicator
	
	expand 2 if year == 2012, gen(dupindicator)
	replace year = 2014 if dupindicator == 1
	drop dupindicator

	expand 2 if year == 2012, gen(dupindicator)
	replace year = 2015 if dupindicator == 1
	drop dupindicator
	
	tab year
	
* Append winners elections 2015
	append using "Data/Elecciones/2015/winners_2015"
	
* Save council data
 save "Data/council_data_2012to2019", replace
