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
	
* Append winners elections 2015
	append using "Data/Elecciones/2015/winners_2015"
	
* Reshape	
	bys muni_code: gen count = _n
	reshape long apellido, i(muni_code count) j(no_apellido)
	
* Drop duplicates in apellido
	drop if mi(apellido)
	
* Get 10 common last names
	preserve
		gen n_lastname = 1
		collapse (count) n_lastname, by(apellido)
		sort n_lastname
		gen popular = 1 if n_lastname>=300
		tempfile common
		save	`common'
	restore
	
	
	duplicates drop muni_code apellido, force
	sort muni_code apellido
	isid muni_code apellido
	merge m:1 apellido using `common', assert(3)
	replace popular = 0 if mi(popular)
	
* Extend data for all years
	replace year = 2012 if year == 2011
	expand 2 if year == 2012, gen(dupindicator)
	replace year = 2013 if dupindicator == 1
	drop dupindicator
	
	expand 2 if year == 2012, gen(dupindicator)
	replace year = 2014 if dupindicator == 1
	drop dupindicator

	expand 2 if year == 2012, gen(dupindicator)
	replace year = 2015 if dupindicator == 1
	drop dupindicator
	
* Extend data for all years
	expand 2 if year == 2016, gen(dupindicator)
	replace year = 2017 if dupindicator == 1
	drop dupindicator
	
	expand 2 if year == 2016, gen(dupindicator)
	replace year = 2018 if dupindicator == 1
	drop dupindicator

	expand 2 if year == 2016, gen(dupindicator)
	replace year = 2019 if dupindicator == 1
	drop dupindicator
	
	tab year
	
	keep muni_code apellido year popular
	isid muni_code apellido year
	
* Save council data
 save "Data/council_data_2012to2019", replace
