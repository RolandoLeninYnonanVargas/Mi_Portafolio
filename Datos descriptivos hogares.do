* Análisis descriptivo laborales ENAHO*
*
*-----------------------------------------------------------------------
*Base ENAHO 2023 – Módulo 5: Empleo e ingreso* ----------------------------------------------------------------------*

cd "Mi ruta personal"

use "enaho01a-2023-500", clear

rename _all, lower

* Exclusión de informantes no válidos
drop if codinfor=="00"

* Selección de miembros habituales del hogar
keep if ((p204==1 & p205==2) | (p204==2 & p206==1))

* Estandarización del código de ubigeo
replace ubigeo="0"+ ubigeo if length(ubigeo)<4
replace ubigeo="0"+ ubigeo if length(ubigeo)<5
replace ubigeo="0"+ ubigeo if length(ubigeo)<6

* Clasificación del área geográfica
tab estrato, m
recode estrato (1/5=1 "Urbano") (else=0 "Rural"), gen(area)
tab area, m

* Construcción de la situación laboral
tab ocu500, m
recode ocu500 (1=1 "Ocupado") (2/3=2 "Desempleado") (else=3 "No PEA"), gen(ocu_2)
tab ocu_2, m

*-----------------------------------------------------------------------
Cálculo de ingresos laborales
-----------------------------------------------------------------------*/

* Tratamiento de valores codificados como no respuesta
replace d529t=. if d529t==999999
replace d536=. if d536==999999
replace d540t=. if d540t==999999
replace d543=. if d543==999999
replace d544t=. if d544t==999999

* Ingresos de la ocupación principal y secundaria
egen r6prin=rsum(i524a1 d529t i530a d536) if ocu_2==1
egen r6sec =rsum(i538a1 d540t i541a d543) if ocu_2==1
gen r6ext=d544t

* Ingreso total
egen r6=rsum(r6prin r6sec r6ext) if ocu_2==1
egen r6_laboral=rsum(r6prin r6sec) if ocu_2==1

* Conversión a ingresos mensuales
replace r6=r6/12
replace r6prin=r6prin/12
replace r6sec=r6sec/12

label var r6 "Ingreso laboral mensual (ocupación principal y secundaria)"
label var r6prin "Ingreso laboral mensual (ocupación principal)"
label var r6sec "Ingreso laboral mensual (ocupación secundaria)"
label var r6_laboral "Ingreso laboral mensual total"
label var r6ext "Ingreso no laboral"

*-----------------------------------------------------------------------
Horas de trabajo
-----------------------------------------------------------------------*/

* Cálculo de horas semanales trabajadas
egen r11=rowtotal(i513t i518) if (ocu_2==1 & p519==1)
replace r11=i520 if (ocu_2==1 & p519==2)

* Promedio de horas trabajadas a nivel del hogar
bysort aÑo mes conglome vivienda hogar: egen horasp_h=mean(r11)
label variable horasp_h "Horas promedio de trabajo semanal del hogar"

*-----------------------------------------------------------------------
Categoría ocupacional
-----------------------------------------------------------------------*/

gen r8=.
replace r8=1 if (p507==1)
replace r8=2 if (p507==3 & inlist(p510,3,4,5,6,7))
replace r8=3 if (p507==3 & inlist(p510,1,2))
replace r8=4 if (p507==4 & inlist(p510,3,4,5,6,7))
replace r8=5 if (p507==4 & inlist(p510,1,2))
replace r8=6 if (p507==2)
replace r8=7 if (p507==5 | p507==7)
replace r8=8 if (p507==6)

label define r8 ///
1 "Empleador" ///
2 "Empleado privado" ///
3 "Empleado público" ///
4 "Obrero privado" ///
5 "Obrero público" ///
6 "Independiente" ///
7 "Trabajador familiar no remunerado" ///
8 "Trabajador del hogar"

label values r8 r8
tab r8, m

* Identificación del sector público
recode r8 (3 5=1 "Sector público") (else=0 "Otros"), gen(r8r)
label var r8r "Condición de empleo en el sector público"

*-----------------------------------------------------------------------
Variables geográficas
-----------------------------------------------------------------------*/

* Dominio geográfico
recode dominio (1 2 3 = 1 "Costa") (4 5 6 = 2 "Sierra") ///
(7 = 3 "Selva") (8 = 4 "Lima Metropolitana"), gen(g_dominio)

* Departamento de residencia
gen departamento=real(substr(ubigeo,1,2))
label values departamento ubicacion

*-----------------------------------------------------------------------
Análisis gráfico
-----------------------------------------------------------------------*/

* Distribución de la condición laboral
gen pet=1
graph pie pet, over(ocu_2) plabel(_all percent) legend(off)

* Distribución etaria
rename p208a edad
histogram edad, normal

* Distribución del ingreso laboral
histogram r6 if ocu_2==1 & r6<=15600, normal

* Comparación del ingreso por área y dominio
graph box r6 if ocu_2==1 & r6<=15600, over(r8r)
graph box r6 if ocu_2==1 & r6<=15600, over(g_dominio)

