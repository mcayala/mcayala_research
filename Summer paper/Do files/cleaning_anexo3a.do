* Project: Summer Paper
* Written by: Camila Ayala (mc.ayala94@gmail.com)
* Purpose: This do file cleans teachers dataset (Anexo 3a)

* Set directory 
	cd "/Volumes/Camila/Dropbox/PhD/Second year/Summer paper"

*------------------------*
* Datasets 2011 and 2013 *
*------------------------*

*------*
* 2013 *
*------*

* These ones need to be cleaned separately because codigo_dane or teacher ID was wrong in the complete dataset	
	
	use "Docentes 2008-2017/BASE_DOCENTES_2013.dta", clear,
	gen year = 2013
	
	* Drop if missing nro_documento
		rename num_doc nro_documento
		drop if nro_documento == " " // 0 obs deleted
		
	* Rename variables for merge
		rename area_ensenanza area_ensenanza_nombrado
		rename area_ensenanza_tec area_ensenanza_tecnica
		rename ultimo_nivel_educativo nivel_educativo_aprobado
		rename tipo_doc tipo_documento
		
	* Day of birth
		split fecha_nacimiento, p("/")
		tab fecha_nacimiento3
		destring fecha_nacimiento3, replace
		gen edad = 2013 - fecha_nacimiento3
		
	keep year nro_documento codigo_dane apellido1 apellido2 nombre1 nombre2 fecha_vinculacion tipo_vinculacion  area_ensenanza_nombrado area_ensenanza_tecnica cargo nivel_ensenanza genero nivel_educativo_aprobado cargo nombre_cargo ubicacion zona tipo_documento edad
	tempfile docentes13
	save	`docentes13'		
	
*------*
* 2011 *
*------*	
import delimited "Anexo 3a/BASE_DOCENTES_2011.csv", clear stringcols(_all)
	gen year = 2011
	
	* Drop if missing nro_documento
		rename num_doc nro_documento
		drop if nro_documento == " " // 1 obs deleted
		
	* Rename variables for merge
		rename area_ensenanza area_ensenanza_nombrado
		rename area_ensenanza_tec area_ensenanza_tecnica
		rename ultimo_nivel_educativo nivel_educativo_aprobado
		rename tipo_doc tipo_documento
	
	* Day of birth
		split fecha_nacimiento, p("/")
		tab fecha_nacimiento3
		destring fecha_nacimiento3, replace
		gen edad = 2011 - fecha_nacimiento3	
	
	keep year nro_documento codigo_dane apellido1 apellido2 nombre1 nombre2 fecha_vinculacion tipo_vinculacion  area_ensenanza_nombrado area_ensenanza_tecnica cargo nivel_ensenanza genero nivel_educativo_aprobado cargo nombre_cargo ubicacion zona tipo_documento edad
	tempfile docentes11
	save	`docentes11'
	
*------*
* 2012 *
*------*
	import delimited "Anexo 3a/BASE_DOCENTES_2012.csv", clear stringcols(_all)
	gen year = 2012
	
	* Drop if missing nro_documento
		rename num_doc nro_documento
		drop if nro_documento == " " // 1 obs deleted
		
	* Rename variables for merge
		rename area_ensenanza area_ensenanza_nombrado
		rename area_ensenanza_tec area_ensenanza_tecnica
		rename ultimo_nivel_educativo nivel_educativo_aprobado
		rename tipo_doc tipo_documento
	
	* Day of birth
		split fecha_nacimiento, p("/")
		tab fecha_nacimiento3
		destring fecha_nacimiento3, replace
		gen edad = 2012 - fecha_nacimiento3	
	
	keep year nro_documento codigo_dane apellido1 apellido2 nombre1 nombre2 fecha_vinculacion tipo_vinculacion  area_ensenanza_nombrado area_ensenanza_tecnica cargo nivel_ensenanza genero nivel_educativo_aprobado cargo nombre_cargo ubicacion zona tipo_documento edad
	tempfile docentes12
	save	`docentes12'	
	
*----------------------*
* Dataset 2012 to 2017 *
*----------------------*	

use "Docentes 2008-2017/DOCENTES_2012_2017.dta", clear

	* Drop if missing nro_documento
		sort nro_documento
		tab anno_inf if nro_documento == " " // its 2013, that's why we copy 
		drop if nro_documento == " " 
		drop if anno_inf == 2012
		
	* Check codigo_dane and nro_documento
		br anno_inf nro_documento codigo_dane codigo_sed
		sort  nro_documento anno_inf codigo_dane
		tab anno_inf if codigo_dane == " " | codigo_dane == "0"
		
	* Rename year
		rename anno_inf year
		
	* Tostring vars for merge
		tostring cargo area_ensenanza_nombrado nivel_ensenanza nivel_educativo_aprobado nombre_cargo ubicacion zona tipo_documento, replace
		destring edad, replace
	
	* Append date for 2011 and 2013
		append using `docentes11'
		append using `docentes12'
		append using `docentes13'
	
	* Check missings
		mdesc year nro_documento codigo_dane apellido1 apellido2 nombre1 nombre2 fecha_vinculacion
	
	* Drop obs where there is no school code
		gen 	miss_codigo_dane = .
		replace miss_codigo_dane = 1 if codigo_dane == ""
		replace miss_codigo_dane = 1 if codigo_dane == " "
		replace miss_codigo_dane = 1 if codigo_dane == "0"
		tab year miss_codigo_dane if codigo_dane == "0"
		drop miss_codigo_dane
		
		drop if codigo_dane == "" // 2,434
		drop if codigo_dane == " " // 9,713 obs
		drop if codigo_dane == "0" // 27,508 obs
	
*------------------*
* Cleaning of vars *
*------------------*	
	
	* Initial variables
		lab var year "Year"
		rename nro_documento document_id
		lab var document_id "Teacher ID"
		rename codigo_dane school_code
		lab var school_code "School code (codigo DANE)"
	
	* Type of ID
		tab year tipo_documento, m
		gen type_id = .
		lab def type_id_l 1 "1: Cedula" 2 "2: Cedula de extranjeria"
		replace type_id = 1 if tipo_documento == "1"
		replace type_id = 2 if tipo_documento == "3"
		lab val type_id type_id_l
		lab var type_id "Document type"
	
	* Age
		tab edad
		gen age = edad
		replace age = . if edad <= 18 & edad >= 80
		lab var age "Teacher's age'"
	
	* Sex
		tab year genero, m
		gen 	female = 1 if inlist(genero, "F", "f")
		replace female = 0 if inlist(genero, "M", "m")
		tab female genero, m
		lab var female "Teacher is female"
		drop genero
		
	* Education level
		tab year nivel_educativo_aprobado, m
		destring nivel_educativo_aprobado, replace
		lab def nivel_educativo_aprobado_l 0 "0: Sin titulo" 1 "1: Bachiller pedagogico" 2 "2: Normalist superior" 3 "3: Otro bachiller" ///
				4 "4: Tecnico o tecnologo en educacion" 5 "5: Tecnico o tecnologo en otras areas" ///
				6 "6: Profesional o licenciado en educacion" 7 "7: Profesional en otras areas, no licenciado" ///
				8 "8: Postgrado en educacion" 9 "9: Postgrado en otras areas"
		lab val nivel_educativo_aprobado nivel_educativo_aprobado_l
		tab nivel_educativo_aprobado
		
		gen educ_level = .
		lab def educ_level_l 0 "0: None" 1 "1: High school" 2 "2: Vocational (Tecnichal and technological)" 3 "3: Bachelor" 4 "4: Posgraduate"
		replace educ_level = 0 if nivel_educativo_aprobado == 0
		replace educ_level = 1 if inlist(nivel_educativo_aprobado, 1, 2, 3)
		replace educ_level = 2 if inlist(nivel_educativo_aprobado, 4, 5)
		replace educ_level = 3 if inlist(nivel_educativo_aprobado, 6, 7)
		replace educ_level = 4 if inlist(nivel_educativo_aprobado, 8, 9)
		lab val educ_level educ_level_l
		tab nivel_educativo_aprobado educ_level, m
		lab var educ_level "Last education level completed"

	* Position
		tab year cargo, m
		gen position = .
		lab def position_l 1 "1: Teacher" 2 "2: Directivo docente"
		replace position = 1 if cargo == "1"
		replace position = 2 if cargo == "2"
		lab val position position_l
		tab position, m
		lab var position "Teacher position"
		
	* Urban /rural
		tab year zona, m
		gen urban = .
		lab def urban_l 1 "1: Urban" 0 "0: Rural"
		replace urban = 1 if zona == "1"
		replace urban = 0 if zona == "2"
		lab val urban urban_l
		lab var urban "Area that teacher attends"
		
	* Type of contract
		tab tipo_vinculacion, m
		destring tipo_vinculacion, replace
		lab def tipo_vinculacion_l 1 "1: Con nombramiento en propiedad" 2 "2: Con nombramiento provisional en una vacante definitiva" ///
				3 "3: Con nombramiento provisional en una vacante temporal" 4 "4: Con nombramiento en periodo de prueba" ///
				5 "5: Con nombramiento Planta temporal"
		lab val tipo_vinculacion tipo_vinculacion_l
		
		gen type_contract = .
		lab def type_contract_l 1 "1: Temporary" 2 "2: Permanent"
		replace type_contract = 1 if inlist(tipo_vinculacion, 2, 3, 5)
		replace type_contract = 2 if inlist(tipo_vinculacion, 1, 4)
		lab val type_contract type_contract_l
		tab tipo_vinculacion type_contract, m
		lab var type_contract "Type of contract"
		
	* Teaching education level
		tab year nivel_ensenanza, m
		destring nivel_ensenanza, replace
		lab def nivel_ensenanza_l 1 "1: Preschool" 2 "2: Primary" 3 "3: Secondary" 4 "4: Normales" 5 "5: N/A"
		lab val nivel_ensenanza nivel_ensenanza_l
		
		clonevar teaching_level = nivel_ensenanza
		replace teaching_level = . if inlist(nivel_ensenanza,0,6)
		tab teaching_level, m
		lab var teaching_level "Teaching level"
		
	* Subject 
		tab year area_ensenanza_nombrado, m
		destring area_ensenanza_nombrado, replace
		rename area_ensenanza_nombrado subject
		lab def subject_l 1 "1: Preescolar" 2 "2: Primaria" 3 "3: Ciencias naturales" ///
				4 "4: Ciencias sociales" 5 "5: Ed artistica: Artes plasticas" 6 "6: Ed artistica: Musica" ///
				7 "7: Ed artistica: artes escenicas" 8 "8: Ed artistica: danzas" 9 "9: Ed fisica" ///
				10 "10: Ed etica" 11 "11: Religion" 12 "12: lengua castellana" 13 "13: Frances" ///
				14 "14: Ingles" 15 "15: Matematicas" 16 "16: Tecnologia e informatica" ///
				17 "17: Quimica" 18 "18: Fisica" 19 "19: Filosofia" 20 "20: Economia" ///
				21 "21: Educ especial" 22 "22: N/A"
		lab val subject subject_l
		lab var subject "Teaching subject"
				
	* Subject tecnica
		tab area_ensenanza_tecnica, m
		gen subject_tec = .
		lab def subject_tec_l 1 "1: Finanzas, administración y seguros" 2 "2: Ventas y servicios" ///
				3 "3: Ciencias naturales y aplicadas" 4 "4: Salud" 5 "5: Ciencias sociales, educación, servicios, gubernamentales y religión" ///
				6 "6: Cultura, arte, esparcimiento y deporte" 7 "7: Explotación primaria y extractiva" ///
				8 "8: Operadores del equipo y transporte instalación y mantenimiento" 9 "9: Procesamiento, fabricación y ensamble" 10 "10: Otras" 11 "11: N/A"
		replace subject_tec = 1 if inlist(area_ensenanza_tecnica, "1", "Finanzas- Administración y Seguros")
		replace subject_tec = 2 if inlist(area_ensenanza_tecnica, "2", "Ventas y Servicios")
		replace subject_tec = 3 if inlist(area_ensenanza_tecnica, "3", "Ciencias Naturales y Aplicadas")
		replace subject_tec = 4 if inlist(area_ensenanza_tecnica, "4", "Salud")
		replace subject_tec = 5 if inlist(area_ensenanza_tecnica, "5", "Ciencias Sociales, Educación, Servicios Gubernamentales")
		replace subject_tec = 6 if inlist(area_ensenanza_tecnica, "6", "Cultura, Arte, Esparcimiento y deporte")
		replace subject_tec = 7 if inlist(area_ensenanza_tecnica, "7", "Explotación Primaria  y Extrativa")
		replace subject_tec = 8 if inlist(area_ensenanza_tecnica, "8", "Operadores de Equipo y Transporte Intalación y Mantenimiento")
		replace subject_tec = 9 if inlist(area_ensenanza_tecnica, "9", "Procesamiento, Fabricación  y Ensamble")
		replace subject_tec = 10 if inlist(area_ensenanza_tecnica, "10", "Otras")
		replace subject_tec = 11 if inlist(area_ensenanza_tecnica, "11", "No plica")
		tab subject subject_tec, m
		lab val subject_tec subject_tec_l
		tab subject subject_tec if position == 1, m
		tab subject subject_tec if position == 2, m // most of N/A are directivos docentes
		lab var subject_tec "Teaching subject - technical"
		
		order year document_id type_id school_code female educ_level position urban type_contract teaching_level subject subject_tec
		sort document_id year
		
	* Check duplicates
		duplicates tag document_id year, gen(dup)
		duplicates tag document_id year school_code, gen(dup2)
		tab1 dup dup2
		drop if dup2 == 1
		drop dup dup2
		
	* Destring nro_documento	
		rename document_id document_id2
		destring document_id2, gen(double document_id) 
		format document_id %16.0g
		order document_id
		drop document_id2
	
*----------------------------*
* For merge with test scores *
*----------------------------*	
	
	* Gen relevant areas
		gen 	subject_icfes = .
		lab def subject_icfes_l 1 "Lectura critica" 2 "Matematicas" 3 "Ciencias naturales" 4 "Sociales y ciudadanas" 5 "Ingles"
		replace subject_icfes = 1 if inlist(subject, 12, 19)
		replace subject_icfes = 2 if inlist(subject, 15)
		replace subject_icfes = 3 if inlist(subject, 3, 17, 18)
		replace subject_icfes = 4 if inlist(subject, 4)
		replace subject_icfes = 5 if inlist(subject, 14)
		lab val subject_icfes subject_icfes_l
		rename subject_icfes icfes_subject
		
*------------------------*
* Cleaning of last names *
*------------------------*

use "Data/base_docentes_clean_2011_2017.dta", clear

	br year apellido1 apellido2 document_id
	sort document_id apellido1 apellido2
	
	* Ñ and accents
		foreach var in apellido1 apellido2 {
			replace `var' = upper(`var')
			replace `var' = subinstr(`var', "Ñ", "N",.)
			replace `var' = subinstr(`var', "Á", "A",.)
			replace `var' = subinstr(`var', "É", "E",.)
			replace `var' = subinstr(`var', "Í", "I",.)
			replace `var' = subinstr(`var', "Ó", "O",.)
			replace `var' = subinstr(`var', "Ú", "U",.)
		}

		foreach var in apellido1 apellido2 {
			replace `var' = "ALVAREZ" if `var' == "?LVAREZ"
			replace `var' = "ARBELAEZ" if `var' == "ARBEL?EZ"
			replace `var' = "ANGULO" if `var' == "?NGULO"
			replace `var' = "AVILA" if `var' == "?VILA"
			replace `var' = "ALEGRIA" if `var' == "ALEGR?A"

		}
		
	* gen tag for weird characters
		foreach var in apellido1  {
			gen tag_`var' = 0 
			replace tag_`var' = 1 if strpos(`var', "Ã?") | strpos(`var', "Ã¿") | strpos(`var', "Ã`'") | strpos(`var', "Ã´") | strpos(`var', "Ã'")
			bys document_id: egen max_tag_`var' = max(tag_`var')
			br document_id year apellido1 apellido2 tag max_tag if max_tag == 1	
			gen `var'_2 = `var' if tag_`var' == 0
			bys document_id: egen `var'_3 = mode(`var'_2)
			replace `var' = `var'_3 if !mi(`var'_3) & max_tag_`var' == 1
			drop `var'_2 `var'_3 tag_`var' max_tag_`var'
		}	
		
	* Manual corrections
		foreach var in apellido1 apellido2 {		
			* spaces
				replace `var' = strtrim(`var')
		}
				
		
	* Save dataset
		*export delimited using "Docentes 2008-2017/base_docentes.csv", replace	
		save "Data/base_docentes_clean_2011_2017.dta", replace

		
		


