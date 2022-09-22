* Project: Summer Paper
* Written by: Camila Ayala (mc.ayala94@gmail.com)
* Purpose: This do file cleans Saber 11 dataset

cd "/Users/camila/Dropbox/PhD/Second year/Summer paper"

*-----------------*
* Import datasets *
*-----------------*

* Resultados individuales
	/*
		foreach x of numlist 20111 20112 20121 20122 20131 20132 20141 20142 20151 20152 20161 20162 20171 20172 {

		display `x'

		clear
		import delimited "Dataicfes/4. Saber11/3. Resultados Saber11/SB11_`x'.txt", delimiter("¬") bindquote(nobind)
		save "Dataicfes/4. Saber11/3. Resultados Saber11/SB11_`x'.dta", replace
		}
	*/
	
* Clasificacion planteles
	foreach x of numlist 2011 {

		display `x'	
		
		clear
		import delimited "Dataicfes/4. Saber11/4. Clasificacion de Planteles/SB11-CLASIFI-PLANTELES-`x'.txt", bindquote(nobind)	
		save "Dataicfes/4. Saber11/4. Clasificacion de Planteles/SB11_`x'.dta", replace

	}

	foreach x of numlist 2012 2013 20142 20152 20162 {

		display `x'	
		
		clear
		import delimited "Dataicfes/4. Saber11/4. Clasificacion de Planteles/SB11-CLASIFI-PLANTELES-`x'.txt", delimiter("|") bindquote(nobind)	
		save "Dataicfes/4. Saber11/4. Clasificacion de Planteles/SB11_`x'.dta", replace

	}	

	clear
	import delimited "Dataicfes/4. Saber11/4. Clasificacion de Planteles/SB11-CLASIFI-PLANTELES-20172.csv",  bindquote(nobind) varnames(1)
	drop v2 v4 v6 v8 v10 v12 v14 v16 v18 v20 v22 v24 v26 v28 v30 v32 v34 v36 v38
	save "Dataicfes/4. Saber11/4. Clasificacion de Planteles/SB11_20172.dta", replace	


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
	
	* Calculate global scores using the forumula in documentation
		gen score_global = 5*(3*score_matematicas + 3*score_lectura_critica + 3*score_c_naturales + 3*score_sociales_ciudadanas + score_ingles)/13
		replace score_global = round(score_global)
		
		bys period: sum punt_global score_global 
		
	*-------------------*
	* Standarize scores *
	*-------------------*
	
	* Drop if missing codigo dane (people who presented individually)
		drop if mi(cole_cod_dane_establecimiento)
		tab cole_naturaleza, m
		
	* Check cole_naturaleza is same for the school
		bys periodo cole_cod_dane_establecimiento: egen min = min(cole_naturaleza)
		bys periodo cole_cod_dane_establecimiento: egen max = max(cole_naturaleza)
		gen a = 1 if (max != min)
		tab cole_cod_dane_establecimiento if a == 1 //only one school -> send to mode
		bys periodo cole_cod_dane_establecimiento: egen mode = mode(cole_naturaleza)
		replace cole_naturaleza = mode if a == 1
		drop mode a min max
		
	* Keep only public schols
		keep if cole_naturaleza == 2
		
	* Standarize
		foreach subject in matematicas lectura_critica c_naturales sociales_ciudadanas ingles global {
			bys periodo: egen std_score_`subject' = std(score_`subject')
		}		
	
	save "Data/SB11_2011_2017_individual.dta", replace
-

*---------------------------------------*		
* Construct dataset at the school level *
*---------------------------------------*		
	
	use "Data/SB11_2011_2017_individual.dta", clear
	
	* Create control vars
		tab estu_genero, gen(stu_sex_)
		rename stu_sex_1 male
		rename stu_sex_2 female
		
		tab fami_estratovivienda, gen(strata_)
		
	* Parents education: high school complete or more
		gen	 	mother_educ = 1 if inlist(fami_educacionmadre, 0, 1, 2, 3)
		replace mother_educ = 0 if inlist(fami_educacionmadre, 4, 5, 6, 7, 8, 9)
		gen	 	father_educ = 1 if inlist(fami_educacionpadre, 0, 1, 2, 3)
		replace father_educ = 0 if inlist(fami_educacionpadre, 4, 5, 6, 7, 8, 9)
		
	* Check municipality code
		rename cole_cod_mcpio_ubicacion muni_code
		bys periodo cole_cod_dane_establecimiento: egen min = min(muni_code)
		bys periodo cole_cod_dane_establecimiento: egen max = max(muni_code)
		gen a = 1 if (max != min)
		br periodo cole_cod_dane_establecimiento muni_code if a == 1
		bys periodo cole_cod_dane_establecimiento: egen mode = mode(muni_code)	
		replace muni_code = mode if a == 1
		merge m:1 muni_code using "${divipola}", assert(2 3) keep(3) nogen
		
	/* Fix muni_code
		gen school_id = string(cole_cod_dane_establecimiento, "%16.0f") 
		gen mpio = substr(school_id, 2, 5)
		destring mpio, replace
	*/	
		
	* Collapse by the school
		collapse (mean) std_* score_* male female strata_* father_educ mother_educ (count) N = score_global (first) muni_code, by(periodo cole_cod_dane_establecimiento)
		rename cole_cod_dane_establecimiento school_code
		sort school_code periodo
		isid school_code periodo

	* Keep only relevant periods
		drop if inlist(periodo, 20111, 20112, 20121)		
		
	* Keep only relevant periods and we keep only first period
		drop if inlist(period, 20121, 20131, 20141, 20151, 20161, 20171)
		
	* Gen year 
		tostring(period), gen(year)
		replace year = substr(year,1,4)
		destring year, replace
		isid school_code year
	
*------------------------------------------*
* Reshape to have a school-subject dataset * 
*------------------------------------------*

	reshape long std_score_ score_ , i(school_code year) j(subject) string
	rename score_ score
	rename std_score_ std_score

	* Gen subject var
		gen 	subject_icfes = .
		lab def subject_icfes_l 1 "Lectura critica" 2 "Matematicas" 3 "Ciencias naturales" 4 "Sociales y ciudadanas" 5 "Ingles"
		replace subject_icfes = 1 if inlist(subject, "lectura_critica")
		replace subject_icfes = 2 if inlist(subject, "matematicas")
		replace subject_icfes = 3 if inlist(subject, "c_naturales")
		replace subject_icfes = 4 if inlist(subject, "sociales_ciudadanas")
		replace subject_icfes = 5 if inlist(subject, "ingles")
		lab val subject_icfes subject_icfes_l
		rename subject_icfes icfes_subject
		drop subject
	
	*rename school_code school_code2
	*tostring school_code2, gen(str20 school_code) force
		
	save "Data/SB11_2011_2017_school_level.dta", replace
	
	
	
	
