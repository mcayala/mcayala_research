* Project: Summer Paper
* Written by: Camila Ayala (mc.ayala94@gmail.com)
* Purpose: This do file cleans council data


* Set directory 
	cd "/Volumes/Camila/Dropbox/PhD/Second year/Summer paper"

	
use "Data/Elecciones/2011/Concejo_2011_Corregida.dta", clear

* Keep people who won a seat
	keep if seats == 1
	rename (first_lastname second_lastname) (apellido1 apellido2)
	isid muni_code apellido1
	
	duplicates tag muni_code apellido1, gen(tag)
