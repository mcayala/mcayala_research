cd "/Volumes/Camila/Dropbox/PhD/Second year/Summer paper"
/*
import delimited "Docentes 2008-2017/DOCENTES_2012_2017.csv", clear 

tab anno_inf
	/*
	 ANNO_INF |      Freq.     Percent        Cum.
	------------+-----------------------------------
		   2012 |    316,714       16.44       16.44
		   2013 |    318,296       16.52       32.96
		   2014 |    320,046       16.61       49.57
		   2015 |    322,037       16.72       66.29
		   2016 |    322,800       16.76       83.05
		   2017 |    326,612       16.95      100.00
	------------+-----------------------------------
		  Total |  1,926,505      100.00
*/

save "Docentes 2008-2017/DOCENTES_2012_2017.dta", replace


use "BASE_DOCENTES_08_13.dta", clear
	tab1 anno_carga anno_inf anno_reporte
	gen 	year = anno_carga
	replace year = anno_reporte if inlist(anno_reporte,2008, 2009,2010, 2011, 2012)
	tab year, m
	drop if year > 2009
	tostring num_doc, replace
	replace nro_documento = num_doc if nro_documento == ""
	drop num_doc
	sort nro_documento
	drop if nro_documento == "."
	br nro_documento codigo_dane apellido1 apellido2 nombre1 nombre2 fecha_vinculacion
	keep year nro_documento codigo_dane apellido1 apellido2 nombre1 nombre2 fecha_vinculacion
	tempfile docentes0809
	save	`docentes0809'
	*/
use "Docentes 2008-2017/BASE_DOCENTES_2008.dta", clear,
	gen year = 2008
	drop if nro_documento == ""
	keep year nro_documento codigo_dane apellido1 apellido2 nombre1 nombre2 fecha_vinculacion
	tempfile docentes08
	save	`docentes08'	
	
use "Docentes 2008-2017/BASE_DOCENTES_2009.dta", clear,
	gen year = 2009
	drop if nro_documento == ""
	keep year nro_documento codigo_dane apellido1 apellido2 nombre1 nombre2 fecha_vinculacion
	tempfile docentes09
	save	`docentes09'
	
use "Docentes 2008-2017/BASE_DOCENTES_2013.dta", clear,
	gen year = 2013
	rename num_doc nro_documento
	drop if nro_documento == " "
	rename area_ensenanza area_ensenanza_nombrado
	rename area_ensenanza_tec area_ensenanza_tecnica
	keep year nro_documento codigo_dane apellido1 apellido2 nombre1 nombre2 fecha_vinculacion tipo_vinculacion  area_ensenanza_nombrado area_ensenanza_tecnica cargo nivel_ensenanza
	tempfile docentes13
	save	`docentes13'		

import delimited "Anexo 3a/BASE_DOCENTES_2010.csv", clear stringcols(_all)
	gen year = 2010
	rename num_doc nro_documento
	drop if nro_documento == " "	
	keep year nro_documento codigo_dane apellido1 apellido2 nombre1 nombre2 fecha_vinculacion
	tempfile docentes10
	save	`docentes10'	
	
import delimited "Anexo 3a/BASE_DOCENTES_2011.csv", clear stringcols(_all)
	gen year = 2011
	rename num_doc nro_documento
	drop if nro_documento == " "
	rename area_ensenanza area_ensenanza_nombrado
	rename area_ensenanza_tec area_ensenanza_tecnica
	keep year nro_documento codigo_dane apellido1 apellido2 nombre1 nombre2 fecha_vinculacion tipo_vinculacion  area_ensenanza_nombrado area_ensenanza_tecnica cargo nivel_ensenanza
	tempfile docentes11
	save	`docentes11'	

use "Docentes 2008-2017/DOCENTES_2012_2017.dta", clear

* Borrar los que no tengo documento
	sort nro_documento
	tab anno_inf if nro_documento == " " // its 2013
	drop if nro_documento == " " 
	
	br anno_inf nro_documento codigo_dane codigo_sed
	sort  nro_documento anno_inf codigo_dane
	
	tab anno_inf if codigo_dane == " " | codigo_dane == "0"
	rename anno_inf year
	tostring cargo area_ensenanza_nombrado nivel_ensenanza, replace
	
	*append using `docentes08'
	*append using `docentes09'
	*append using `docentes10'
	append using `docentes11'
	append using `docentes13'
	
	mdesc year nro_documento codigo_dane apellido1 apellido2 nombre1 nombre2 fecha_vinculacion
	
	drop if codigo_dane == "" // 2,477
	drop if codigo_dane == " " // 9,713 obs
	drop if codigo_dane == "0" // 14,139 obs
	
	tab year
	keep year nro_documento codigo_dane apellido1 apellido2 nombre1 nombre2 fecha_vinculacion tipo_vinculacion edad estatuto area_ensenanza_nombrado area_ensenanza_tecnica cargo nivel_ensenanza
	order year nro_documento codigo_dane apellido1 apellido2 nombre1 nombre2 fecha_vinculacion 
	sort nro_documento year
	
	duplicates tag nro_documento year, gen(dup)
	duplicates tag nro_documento year codigo_dane, gen(dup2)
	tab1 dup dup2
	drop if dup2 == 1
	
	*keep year nro_documento codigo_dane 
	tab year
	drop dup dup2
	destring nro_documento, gen(double document_id) 
	format document_id %16.0g
	
export delimited using "Docentes 2008-2017/base_docentes.csv", replace	
save "Docentes 2008-2017/base_docentes_2022-05-18.dta", replace
	
	