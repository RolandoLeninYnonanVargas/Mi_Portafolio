*****************************************************
* Paper: Mujeres rurales y el uso de teléfonos móviles en el Perú. Efecto en el empoderamiento con visión de capital humano
* Docente: Soledad Ruiz Lopez
* Autor de Dofile: Rolando Lenin Ynoñan Vargas
*****************************************************

*****************************************************
* MÓDULO 300 - TICs y características demográficas
*****************************************************

clear all
set more off

* Ruta de trabajo
cd "C:\Users\Rolando Ynoñan V\Desktop\ROLANDO-UNI\Expertise\INDICADORES SOCIOECONOMICOS"

* Configuración de codificación (evita problemas de acentos)
unicode analyze *
unicode encoding set ISO-8859-1
unicode translate *

* Unir bases ENAHO (2017-2019)
use "enaho01a-2019-300", clear
append using "enaho01a-2018-300" "enaho01a-2017-300"

* Asegurar año numérico
rename aÑo año
destring año, replace

* Indicador de residencia habitual
gen residente = ((p204==1 & p205==2) | (p204==2 & p206==1))

* Zona: 0 = Urbano, 1 = Rural
gen rural = .
replace rural = 0 if inrange(estrato,1,5)
replace rural = 1 if inrange(estrato,6,8)
label define lb_rural 0 "Urbano" 1 "Rural"
label values rural lb_rural

* Sexo: 0 = Hombre, 1 = Mujer
gen sexo = .
replace sexo = 0 if p207==1
replace sexo = 1 if p207==2
label define lb_sexo 0 "Hombre" 1 "Mujer"
label values sexo lb_sexo

* Variables de uso de teléfono móvil
rename p316a1 movil_propio
rename p316a2 movil_propio_familiar
rename p316a3 movil_propio_trabajo

* Años de educación
gen año_est = .
quietly {
    replace año_est=0 if p301a<=2
    replace año_est=1 if p301a==3 & p301b==0
    replace año_est=2 if p301a==3 & p301b==1
    replace año_est=3 if p301a==3 & p301b==2
    replace año_est=4 if p301a==3 & p301b==3
    replace año_est=5 if p301a==3 & inlist(p301b,4,5)
    replace año_est=6 if p301a==4 & inlist(p301b,5,6)
    replace año_est=7 if p301a==5 & p301b==1
    replace año_est=8 if p301a==5 & p301b==2
    replace año_est=9 if p301a==5 & p301b==3
    replace año_est=10 if p301a==5 & inlist(p301b,4,5)
    replace año_est=11 if p301a==6 & inlist(p301b,5,6)
    replace año_est=12 if p301a==7 & p301b==1
    replace año_est=13 if p301a==7 & p301b==2
    replace año_est=14 if p301a==7 & inlist(p301b,3,4)
    replace año_est=14 if p301a==8 & p301b==3
    replace año_est=15 if p301a==8 & inlist(p301b,4,5)
    replace año_est=12 if p301a==9 & p301b==1
    replace año_est=13 if p301a==9 & p301b==2
    replace año_est=14 if p301a==9 & p301b==3
    replace año_est=15 if p301a==9 & inlist(p301b,4,5,6)
    replace año_est=15 if p301a==10 & p301b==4
    replace año_est=16 if p301a==10 & inlist(p301b,5,6,7)
    replace año_est=16 if p301a==11 & inlist(p301b,1,2)
    replace año_est=p301b if p301a==12 & p301b!=0
    replace año_est=p301c if p301a==12 & missing(año_est)
}

* Estado civil y jefatura
gen soltera = (p209==6)
gen jefehogar = (p203==1)

* Filtrar: Mujeres rurales residentes
keep if residente==1 & rural==1 & sexo==1

* Guardar base módulo 300 (sin fac500a)
keep año conglome vivienda hogar estrato residente rural sexo movil_propio movil_propio_familiar movil_propio_trabajo año_est soltera jefehogar
save "Base de datos paper - M300.dta", replace


*****************************************************
* MÓDULO 500 - Empleo e ingresos
*****************************************************

clear all
cd "C:\Users\Rolando Ynoñan V\Desktop\ROLANDO-UNI\Expertise\INDICADORES SOCIOECONOMICOS"

unicode analyze *
unicode encoding set ISO-8859-1
unicode translate *

use "enaho01a-2019-500", clear
append using "enaho01a-2018-500" "enaho01a-2017-500"

rename aÑo año
destring año, replace

* Diseño muestral (svyset se aplicará después del merge)
drop if codinfor=="00"
gen residente = ((p204==1 & p205==2) | (p204==2 & p206==1))

gen rural = .
replace rural = 0 if inrange(estrato,1,5)
replace rural = 1 if inrange(estrato,6,8)

gen sexo = .
replace sexo = 0 if p207==1
replace sexo = 1 if p207==2

* Mercado laboral
gen pet = 1
gen pea = .
replace pea = 1 if inlist(ocu500,1,2)
replace pea = 0 if inlist(ocu500,3,4)
gen tasa_act = (pet==1 & pea==1)

* Experiencia laboral
rename p513a1 años_exp
drop if missing(años_exp)
gen años_exp_2 = años_exp^2

* Estado civil y jefatura
gen soltera = (p209==6)
gen jefehogar = (p203==1)

* Relación laboral e ingresos
recode p507 (3/4=1) (2=2) (1=3) (5/7=4), gen(relacion_laboral)
rename (p513t p523 p524a1 p530a) (horas_sem_principal frecuencia ingreso_por_pago ingreso_mensual_independiente)
recode frecuencia (1=26) (2=4) (3=2) (4=1), gen(pagos_por_mes)

replace ingreso_mensual_independiente=. if ingreso_mensual_independiente==999999
gen ingreso_mensual = ingreso_por_pago*pagos_por_mes
replace ingreso_mensual = ingreso_mensual_independiente if inlist(relacion_laboral,2,3)
drop if missing(ingreso_mensual)

* Filtrar: Mujeres rurales ocupadas con ingresos
keep if residente==1 & rural==1 & sexo==1 & tasa_act==1 & ingreso_mensual>0

* Guardar base módulo 500 (manteniendo fac500a y estrato)
keep año conglome vivienda hogar estrato fac500a residente rural sexo soltera jefehogar ingreso_mensual pet pea tasa_act años_exp años_exp_2
save "Base de datos paper - M500.dta", replace


*****************************************************
* COMBINACIÓN DE BASES
*****************************************************

clear all
cd "C:\Users\Rolando Ynoñan V\Desktop\ROLANDO-UNI\Expertise\INDICADORES SOCIOECONOMICOS"

use "Base de datos paper - M300.dta", clear
merge m:m año conglome vivienda hogar using "Base de datos paper - M500.dta"
keep if _merge==3
drop _merge
save "Base de datos paper - final.dta", replace


*****************************************************
* ESTIMACIONES (basadas en código 2)
*****************************************************

use "Base de datos paper - final.dta", clear

* Definir diseño muestral
svyset [pw=fac500a], strata(estrato) psu(conglome)

* Modelo lineal
svy: regress ingreso_mensual movil_propio año_est años_exp años_exp_2 soltera jefehogar

* Modelo Probit
svy: probit movil_propio año_est años_exp años_exp_2 soltera jefehogar

* Promedio por año
svy: mean ingreso_mensual, over(año)

*****************************************************
* Fin del Do
*****************************************************


