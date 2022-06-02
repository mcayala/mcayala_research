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

	foreach x of numlist 20141 20142 20151 20152 20161 20162 20171 20172 {

	display `x'

	clear
	import delimited "Dataicfes/4. Saber11/3. Resultados Saber11/SB11_`x'.txt", delimiter("¬") bindquote(nobind)

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
		lab def educ_l 0 "Ninguno" 1 "Primaria incompleta" 2 "Primaria completa"  3 "Secundaria (Bachillerato) incompleta" 4 "Secundaria (Bachillerato) completa" 5 "Técnica o tecnológica incompleta" 6 "Técnica o tecnológica completa" 7 "Educación profesional completa" 8 "Educación profesional incompleta" 9 "Postgrado" -98 "No sabe"
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
			replace `var' = 7 if `var'_old == "Educación profesional completa"
			replace `var' = 8 if `var'_old == "Educación profesional incompleta"
			replace `var' = 9 if `var'_old == "Postgrado"
			replace `var' = -98 if `var'_old == "No sabe"
			lab val `var' educ_l
		}
		
	* Some family assets	
		foreach var of FAMI_TIENEINTERNET
		
		keep estu_genero estu_fechanacimiento fami_estratovivienda fami_educacionpadre fami_educacionmadre
	
	save "Dataicfes/4. Saber11/3. Resultados Saber11/SB11_`x'.dta", replace

	}


	
	
	
	
* Append datasets
	use "Dataicfes/4. Saber11/3. Resultados Saber11/SB11_20142.dta", clear
	foreach x of numlist 20142 20151 20152 20161 20162 20171 20172 {
		append using "Dataicfes/4. Saber11/3. Resultados Saber11/SB11_`x'.dta"
	}
	
	foreach var of varlist estu_tipodocumento estu_genero estu_estudiante estu_etnia estu_areareside estu_areareside estu_valorpensioncolegio estu_vecespresentoexamen fami_educacionpadre fami_educacionmadre fami_ocupacionpadre fami_ocupacionmadre fami_estratovivienda fami_nivelsisben fami_pisoshogar   {
		tab `var'
		rename `var' `var'_old
		encode `var'_old, gen(`var')
		order `var', after(`var'_old)
		drop `var'_old
	}

	foreach var of varlist estu_limita_motriz estu_limita_invidente estu_limita_condicionespecial estu_limita_sordo estu_limita_sdown estu_limita_autismo {
		rename `var' `var'2
		gen `var' = (`var'2 == "x")
		order `var', after(`var'2)
		
	}


	encode estu_tipodocumento, gen(estu_tipodocumento_new)
	
* Keep only students
	tab estu_estudiante
