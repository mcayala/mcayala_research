* Project: Summer Paper
* Written by: Camila Ayala (mc.ayala94@gmail.com)
* Purpose: This do file cleans Saber 11 dataset

cd "/Volumes/Camila/Dropbox/PhD/Second year/Summer paper"

*-----------------*
* Import datasets *
*-----------------*
/*
	foreach x of numlist 20111 20112 20121 20122 20131 20132 20141 20142 20151 20152 20161 20162 20171 20172 {

	display `x'

	clear
	import delimited "Dataicfes/4. Saber11/3. Resultados Saber11/SB11_`x'.txt", delimiter("¬") bindquote(nobind)

	save "Dataicfes/4. Saber11/3. Resultados Saber11/SB11_`x'.dta", replace

	}
*/
	
*------------------------*
* Cleaning 20142 - 20172 *
*------------------------*

	foreach x of numlist 20111 20112 20121 20122 20131 20132 20141 20142 20151 20152 20161 20162 20171 20172 {

	display `x'

	clear
	use "Dataicfes/4. Saber11/3. Resultados Saber11/SB11_`x'.dta", clear

	* Genero
		rename estu_genero estu_genero_old
		gen 	estu_genero = 1 if estu_genero_old == "F"
		replace estu_genero = 0 if estu_genero_old == "M"
		lab def estu_genero_l 1 "Female" 0 "Male"
		lab val estu_genero estu_genero_l
	
	* Date of birth
		rename estu_fechanacimiento estu_fechanacimiento_old
		gen estu_fechanacimiento = date(estu_fechanacimiento_old,"DMY")
		format estu_fechanacimiento %td
		
	* Strata
		rename fami_estratovivienda fami_estratovivienda_old
		gen 	fami_estratovivienda = 1 if fami_estratovivienda_old == "Estrato 1"
		replace fami_estratovivienda = 2 if fami_estratovivienda_old == "Estrato 2"
		replace fami_estratovivienda = 3 if fami_estratovivienda_old == "Estrato 3"
		replace fami_estratovivienda = 4 if fami_estratovivienda_old == "Estrato 4"
		replace fami_estratovivienda = 5 if fami_estratovivienda_old == "Estrato 5"
		replace fami_estratovivienda = 6 if fami_estratovivienda_old == "Estrato 6"
		replace fami_estratovivienda = 0 if fami_estratovivienda_old == "Sin estrato" | fami_estratovivienda_old == "Sin Estrato"
	
	* Parents education
		lab def educ_l 0 "Ninguno" 1 "Primaria incompleta" 2 "Primaria completa"  3 "Secundaria (Bachillerato) incompleta" 4 "Secundaria (Bachillerato) completa" 5 "Técnica o tecnológica incompleta" 6 "Técnica o tecnológica completa" 7 "Educación profesional incompleta" 8 "Educación profesional completa" 9 "Postgrado" -99 "No aplica" -98 "No sabe"
		foreach var in fami_educacionpadre fami_educacionmadre {
			rename `var' `var'_old
			gen `var' = .
			replace `var' = 0 if `var'_old == "Ninguno"
			replace `var' = 1 if `var'_old == "Primaria incompleta"
			replace `var' = 2 if `var'_old == "Primaria completa"
			replace `var' = 3 if `var'_old == "Secundaria (Bachillerato) incompleta"
			replace `var' = 4 if `var'_old == "Secundaria (Bachillerato) completa"
			replace `var' = 5 if `var'_old == "Técnica o tecnológica incompleta"
			replace `var' = 6 if `var'_old == "Técnica o tecnológica completa"
			replace `var' = 7 if `var'_old == "Educación profesional incompleta"
			replace `var' = 8 if `var'_old == "Educación profesional completa"
			replace `var' = 9 if `var'_old == "Postgrado"
			replace `var' = -98 if `var'_old == "No sabe"
			replace `var' = -99 if `var'_old == "No Aplica"
			lab val `var' educ_l
		}
		
	* Some family assets	
		foreach var of varlist fami_tieneinternet fami_tienecomputador fami_tienelavadora fami_tieneautomovil { //fami_tieneserviciotv
			rename `var' `var'_old
			gen 	`var' = 1 if `var'_old == "Si"
			replace `var' = 0 if `var'_old == "No"
		}
		
	* School vars
		cap destring cole_cod_dane_sede, replace
		format cole_cod_dane_establecimiento cole_cod_dane_sede %16.0g
		
		* school gender
			rename cole_genero cole_genero_old
			lab def cole_genero_l 1 "Femenino" 2 "Masculino" 3 "Mixto"
			gen 	cole_genero = 1 if cole_genero_old == "FEMENINO"
			replace cole_genero = 2 if cole_genero_old == "MASCULINO"
			replace cole_genero = 3 if cole_genero_old == "MIXTO"
			lab val cole_genero cole_genero_l
			
		* Cole naturaleza
			rename cole_naturaleza cole_naturaleza_old
			lab def cole_naturaleza_l 1 "No oficial" 2 "Oficial"
			gen 	cole_naturaleza = 1 if cole_naturaleza_old == "NO OFICIAL"
			replace cole_naturaleza = 2 if cole_naturaleza_old == "OFICIAL"
			lab val cole_naturaleza cole_naturaleza_l
			
		* Cole calendario
			rename cole_calendario cole_calendario_old
			lab def cole_calendario_l 1 "A" 2 "B" 3 "Otro"
			gen 	cole_calendario = 1 if cole_calendario_old == "A"
			replace cole_calendario = 2 if cole_calendario_old == "B"
			replace cole_calendario = 3 if cole_calendario_old == "OTRO"
			lab val cole_calendario cole_calendario_l
			
		* Cole bilingue
			rename cole_bilingue cole_bilingue_old
			lab def cole_bilingue_l 1 "Si" 0 "No"
			gen cole_bilingue = 1 if cole_bilingue_old == "S"
			replace cole_bilingue = 0 if cole_bilingue_old == "N"
			lab val cole_bilingue cole_bilingue_l
		
		* Cole caracter
			rename cole_caracter cole_caracter_old
			lab def cole_caracter_l 1 "ACADÉMICO" 2 "TÉCNICO" 3 "TÉCNICO/ACADMÉMICO" 4 "N/A"
			gen 	cole_caracter = 1 if cole_caracter_old == "ACADÉMICO"
			replace cole_caracter = 2 if cole_caracter_old == "TÉCNICO"
			replace cole_caracter = 3 if cole_caracter_old == "TÉCNICO/ACADÉMICO"
			replace cole_caracter = 4 if cole_caracter_old == "NO APLICA"
			lab val cole_caracter cole_caracter_l
		 
if inlist(`x', 20122, 20131, 20132, 20141) {
	di "loop 1"
			destring punt_matematicas punt_ingles punt_ciencias_sociales punt_biologia punt_filosofia punt_fisica punt_quimica punt_lenguaje punt_interdisc_medioambiente punt_interdisc_violenciaysoc punt_profundiza_biologia punt_profundiza_csociales punt_profundiza_lenguaje punt_profundiza_matematica, replace force
	keep periodo estu_genero estu_consecutivo estu_estudiante estu_fechanacimiento estu_depto_reside estu_cod_reside_depto estu_mcpio_reside estu_cod_reside_mcpio fami_estratovivienda fami_educacionpadre fami_educacionmadre fami_tieneinternet fami_tienecomputador fami_tienelavadora  fami_tieneautomovil cole_cod_dane_establecimiento cole_genero cole_naturaleza cole_calendario cole_bilingue cole_caracter cole_cod_mcpio_ubicacion cole_mcpio_ubicacion cole_cod_depto_ubicacion cole_depto_ubicacion punt_matematicas punt_ciencias_sociales punt_filosofia punt_ingles desemp_ingles punt_fisica punt_lenguaje punt_quimica punt_biologia punt_interdisc_medioambiente punt_interdisc_violenciaysoc punt_profundiza_biologia desemp_profundiza_biologia punt_profundiza_csociales desemp_profundiza_csociales punt_profundiza_lenguaje desemp_profundiza_lenguaje punt_profundiza_matematica desemp_profundiza_matematica estu_puesto *_old recaf_*
	}			
else if inlist(`x', 20142, 20151, 20152) {
			di "loop 2"
		keep periodo estu_genero estu_consecutivo estu_estudiante estu_fechanacimiento estu_depto_reside estu_cod_reside_depto estu_mcpio_reside estu_cod_reside_mcpio fami_estratovivienda fami_educacionpadre fami_educacionmadre fami_tieneinternet fami_tienecomputador fami_tienelavadora  fami_tieneautomovil cole_cod_dane_establecimiento cole_genero cole_naturaleza cole_calendario cole_bilingue cole_caracter cole_cod_mcpio_ubicacion cole_mcpio_ubicacion cole_cod_depto_ubicacion cole_depto_ubicacion punt_lectura_critica  punt_matematicas  punt_c_naturales  punt_sociales_ciudadanas  punt_razona_cuantitativo  punt_comp_ciudadana  punt_ingles  desemp_ingles punt_global estu_puesto *_old
	}
else if inlist(`x', 20111, 20112, 20121) {
			di "loop 3"
			destring punt_matematicas punt_ingles punt_ciencias_sociales punt_biologia punt_filosofia punt_fisica punt_quimica punt_lenguaje punt_interdisc_medioambiente punt_interdisc_violenciaysoc punt_profundiza_biologia punt_profundiza_csociales punt_profundiza_lenguaje punt_profundiza_matematica, replace force
	keep periodo estu_genero estu_consecutivo estu_estudiante estu_fechanacimiento estu_depto_reside estu_cod_reside_depto estu_mcpio_reside estu_cod_reside_mcpio fami_estratovivienda fami_educacionpadre fami_educacionmadre fami_tieneinternet fami_tienecomputador fami_tienelavadora  fami_tieneautomovil cole_cod_dane_establecimiento cole_genero cole_naturaleza cole_calendario cole_bilingue cole_caracter cole_cod_mcpio_ubicacion cole_mcpio_ubicacion cole_cod_depto_ubicacion cole_depto_ubicacion punt_matematicas punt_ciencias_sociales punt_filosofia punt_ingles desemp_ingles punt_fisica punt_lenguaje punt_quimica punt_biologia punt_interdisc_medioambiente punt_interdisc_violenciaysoc punt_profundiza_biologia desemp_profundiza_biologia punt_profundiza_csociales desemp_profundiza_csociales punt_profundiza_lenguaje desemp_profundiza_lenguaje punt_profundiza_matematica desemp_profundiza_matematica estu_puesto *_old
	}

else {
			di "loop 4"
			keep periodo estu_genero estu_consecutivo estu_estudiante estu_fechanacimiento estu_depto_reside estu_cod_reside_depto estu_mcpio_reside estu_cod_reside_mcpio fami_estratovivienda fami_educacionpadre fami_educacionmadre fami_tieneinternet fami_tienecomputador fami_tienelavadora  fami_tieneautomovil cole_cod_dane_establecimiento cole_genero cole_naturaleza cole_calendario cole_bilingue cole_caracter cole_cod_mcpio_ubicacion cole_mcpio_ubicacion cole_cod_depto_ubicacion cole_depto_ubicacion punt_lectura_critica  punt_matematicas  punt_c_naturales  punt_sociales_ciudadanas   punt_ingles  desemp_ingles punt_global *_old
		}
		
	save "Dataicfes/4. Saber11/3. Resultados Saber11/SB11_`x'_clean.dta", replace

	}
	
	
	
* Append datasets
	use "Dataicfes/4. Saber11/3. Resultados Saber11/SB11_20111_clean.dta", clear
	foreach x of numlist 20112 20121 20122 20131 20132 20141 20142 20151 20152 20161 20162 20171 20172 {
		append using "Dataicfes/4. Saber11/3. Resultados Saber11/SB11_`x'_clean.dta"
	}
	
	* Check variables are okay
		tab estu_genero_old estu_genero, m
		tab fami_educacionpadre_old fami_educacionpadre, m
		tab fami_educacionmadre_old fami_educacionmadre, m
		tab fami_estratovivienda_old fami_estratovivienda, m
		tab fami_tieneinternet_old fami_tieneinternet, m
		tab fami_tienecomputador_old fami_tienecomputador, m
		tab fami_tienelavadora_old fami_tienelavadora, m
		tab fami_tieneautomovil_old fami_tieneautomovil, m
		tab cole_genero_old cole_genero, m
		tab cole_naturaleza_old cole_naturaleza, m
		tab cole_calendario_old cole_calendario, m
		tab cole_bilingue_old cole_bilingue, m 
		tab cole_caracter_old cole_caracter, m
		drop *_old
		
*------------------*		
* Construct scores *
*------------------*		
	
	* Info can be found in "Dropbox/PhD/Second year/Summer paper/Dataicfes/4. Saber11/2. Documentación/1. Saber11/1. Documentación_Saber11.pdf"
		
	*------------------*
	* 2012-2 to 2014-1 *
	*------------------*
	
	* Scores was re-scored to be comparable with 2014-2 onwards
		bys periodo: mdesc recaf_*
		
	* Replace scores
		foreach subject in matematicas lectura_critica c_naturales sociales_ciudadanas ingles {
			gen 	score_`subject' = .
			replace score_`subject' = recaf_punt_`subject' if inlist(periodo, 20122, 20131, 20132, 20141)
		}		
		
	*----------------*
	* 2014-2 onwards *
	*----------------*
		
	* Final 5 areas: math, critic reading, natural science, social science, english
		foreach subject in matematicas lectura_critica c_naturales sociales_ciudadanas ingles {
			replace score_`subject' = punt_`subject' if inlist(periodo, 20142, 20151, 20152, 20161, 20162, 20171, 20172)
		}
		bys period: sum score_*
		
		
	*--------------*
	* Global score *
	*--------------*
	
	
		
		
	bys periodo: sum punt_matematicas punt_lectura_critica  punt_c_naturales punt_sociales_ciudadanas punt_ingles punt_global
	
	
	
	save "Data/SB11_2011_2017_individual.dta", replace

	
	
	
	
	
	
	recaf_punt_sociales_ciudadanas recaf_punt_ingles recaf_punt_lectura_critica recaf_punt_matematicas recaf_punt_c_naturales
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	