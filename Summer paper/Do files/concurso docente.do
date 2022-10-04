import delimited "/Users/camila/Dropbox/Maestria/Tesis/Servidor/Saber 11/Fuentes/Concurso docentes/5_JUL_2009.csv", clear 

rename documento document_id
destring document_id, replace force

duplicates tag document_id, gen(tag)
tab tag 
drop if tag > 0 // only 12 people


merge 1:m document_id using "Data/merge_JF_teachers_secundaria.dta", gen(merge)

