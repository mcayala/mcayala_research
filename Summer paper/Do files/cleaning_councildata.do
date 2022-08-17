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
	bys muni_code year: gen count = _n
	reshape long apellido, i(muni_code year count) j(no_apellido)
	
* Ñ and accents
	foreach var in apellido {
		replace `var' = upper(`var')
		replace `var' = subinstr(`var', "Ñ", "N",.)
		replace `var' = subinstr(`var', "Á", "A",.)
		replace `var' = subinstr(`var', "É", "E",.)
		replace `var' = subinstr(`var', "Í", "I",.)
		replace `var' = subinstr(`var', "Ó", "O",.)
		replace `var' = subinstr(`var', "Ú", "U",.)
		replace `var' = subinstr(`var', "Ü", "U",.)
		replace `var' = strtrim(`var')
	}	
		
* Drop duplicates in apellido
	drop if mi(apellido)
	
* Get 10 common last names
	preserve
		gen n_lastname = 1
		collapse (count) n_lastname, by(apellido)
		sort n_lastname
		gen popular = 1 if n_lastname>=300
		replace popular = 0 if mi(popular)
		tempfile common
		save	`common'
	restore
	
	duplicates drop muni_code year apellido, force
	sort muni_code year apellido
	isid muni_code year apellido
	merge m:1 apellido using `common', assert(3)
	
* Extend data for all years
	tab year
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
	
	keep muni_code apellido year
	isid muni_code apellido year

* Save council data
 save "Data/council_data_2012to2019", replace
