/*
===============================================================================
ANÁLISIS DE SALUD PÚBLICA - CIUDAD DE ROSARIO (SANTA FE)
===============================================================================
Resolución de práctica profesional utilizando SQL.
Fuente de datos: https://datos.rosario.gob.ar/
*/

-- A continuación se plantean un conjunto de ejercicios utilizando el modelo de Salud públicas de la Ciudad de Rosario (Santa Fé)
-- https://datos.rosario.gob.ar/
-- El modelo cuenta con las siguientes tablas:
-- ● Pacientes: Listado de pacientes internados en instituciones de salud de la ciudad de Rosario. Incluye id, nombre, apellido, edad, nacionalidad y sexo.
-- ● Hospitales: Listado de instituciones de salud resgistradas en el sistema. Incluye identificador, nombre, dirección, distrito, titular y cantidad de camas.
-- ● Diagnosticos: Listado de los tipos de diagnosticos de los pacientes internados. Incluye identificador, nombre del diagnostico y servicio.
-- ● Sectores: Registro de los sectores de las instituciones.
-- ● Internaciones: Información de las internaciones realizadas entre 2019-2022. Incluye el identificador de internación, paciente, diagnostico, sector, fecha de internación, dias de internacion y motivo de egreso

USE curso.salud;

-- 1. Listar el contenido de la tabla diagnosticos
SELECT * FROM diagnosticos;

-- 2. Listar el nombre, calle y altura de los hospitales que sean de tipo Provincial
SELECT nombre, calle, altura
FROM hospitales
WHERE titular = 'Provincial';

-- 3. Continuando con la consulta anterior generar un campo dirección que sea la calle y altura. Quitar "espacios" en caso de ser necesario
SELECT nombre, concat(trim(calle),' ' , altura) AS direccion
FROM hospitales
WHERE titular = 'Provincial';

-- 4. Listar todos los hospitales que sean de tipo Municipal y que pertenezcan al distrito oeste o sur
SELECT *
FROM hospitales
WHERE titular = 'Municipal' AND distrito IN ('oeste','sur');

-- 5. ¿y que tengan entre 100 y 200 camas?
SELECT *
FROM hospitales
WHERE titular = 'Municipal' AND distrito IN ('oeste','sur') AND cantidad_camas BETWEEN 100 AND 200;

-- 6. ¿Cuales son los tipos de egresos posibles de los pacientes?. Ordenar alfabeticamente
SELECT DISTINCT tipo_egreso FROM internaciones ORDER BY tipo_egreso;

-- 7. Generar un reporte que muestre las internaciones del año 2022 que estuvieron al menos un mes internado y el tipo de egreso no sea defuncion. El reporte debe contener:
-- ● Fecha de internación
-- ● ID de internación
-- ● ID de hospital
-- ● ID del paciente
-- ● cantidad de dias internado
-- ● motivo de egreso
-- ● Primero se deben mostrar las internaciones más recientes y luego por tipo de egreso alfabeticamente

SELECT 
  fecha AS fecha_internacion,
  id_internacion,
  id_hospital,
  id_paciente,
  dias_internacion,
  tipo_egreso
FROM internaciones
WHERE YEAR(fecha) = 2022 AND dias_internacion > 30 AND tipo_egreso <> 'Defuncion'
ORDER BY fecha DESC, tipo_egreso ASC;

-- 8. Obtener los nombres de los hospitales que no tienen la palabra "salud" en su nombre, ordenados por distrito
SELECT nombre, distrito
FROM hospitales
WHERE nombre NOT LIKE '%Salud%'
ORDER BY distrito ASC;

-- 9. Mostrar los pacientes que sean mayores de edad y del sexo femenino
SELECT * FROM pacientes
WHERE edad >= 18 AND sexo ='F';

-- 10. Listar los pacientes, fecha y cantidad de dias de internacion de los sectores que comiencen con "C" de las internaciones que no tengan motivo de egreso. En el listado completar el tipo de egreso por la descripción Sin Especificar
SELECT id_paciente, fecha, dias_internacion, coalesce(tipo_egreso, 'Sin especificar') AS tipo_egreso
FROM internaciones
WHERE tipo_egreso IS NULL AND id_sector LIKE 'C%';

-- 11. Existen pacientes que no sean de nacionalidad Argentina y que sean menores de edad o mayores a los 65 años? En caso de existir, listar el nombre completo (en un solo campo), edad y nacionalidad.
SELECT 
  concat(nombre,' ',apellido) AS nombre_completo, 
  edad, 
  nacionalidad 
FROM pacientes
WHERE (edad < 18 OR edad > 65) AND nacionalidad <> 'Argentina';

-- 12. Desde el sector de administración nos solicitan que aseguremos la calidad de los datos y normalizemos los datos de los hospitales. Por lo tango debemos generar un listado de los hospitales que contenga los siguientes campos:
-- ● Nombre del hospital, eliminar espacios innecesarios.
-- ● Dirección, unificar y eliminar espacios innecesarios. Ademas, dejar sólo la primer letra en mayuscula
-- ● Distrito, eliminar espacios inncesarios y dejar solo primer letra en mayuscula
-- ● Cantidad de camas
SELECT 
  trim(nombre) as nombre_hospital,
  initcap(concat(trim(calle), ' ', altura)) as direccion,
  initcap(distrito) as distrito,
  cantidad_camas
FROM hospitales;

-- 13. Calcular la edad promedio de los pacientes por sexo
SELECT 
  sexo, 
  AVG(edad) AS edad_promedio
FROM pacientes
GROUP BY sexo;

-- 14. Calcular el promedio de días de internación de los pacientes por tipo de egreso para el año 2021. En caso que no este catalogado el tipo de egreso completar con "Sin tipo"
SELECT 
  COALESCE(tipo_egreso,'Sin tipo') AS tipo_egreso,
  AVG(dias_internacion) AS prom_dias_internacion
FROM internaciones
WHERE YEAR(fecha)=2021
GROUP BY tipo_egreso;

-- 15. Contar la cantidad de internaciones por diagnóstico, pero solo para aquellos diagnósticos con más de 50 internaciones
SELECT 
  id_diagnostico, 
  COUNT(*) AS cantidad_internaciones
FROM internaciones
GROUP BY id_diagnostico
HAVING COUNT(*) > 50;

-- 16. Obtener un listado de hospitales que muestre la cantidad minima, maxima y promedio de internacion por año. Ordenar el resultado por hospital y año de manera ascendente.
SELECT
  id_hospital,
  extract(YEAR from fecha) AS anio_internacion,
  min(dias_internacion) AS min_dias_internacion,
  max(dias_internacion) AS max_dias_internacion,
  avg(dias_internacion) AS prom_dias_internacion
FROM internaciones
GROUP BY id_hospital, extract(YEAR from fecha) 
ORDER BY id_hospital, extract(YEAR from fecha) ASC;

-- 17. Encontrar el día de la semana con más internaciones en promedio
SELECT 
  dayofweek(fecha) AS dia_semana, 
  AVG(dias_internacion) AS promedio_estadia
FROM internaciones 
GROUP BY dayofweek(fecha) 
ORDER BY dayofweek(fecha) DESC
LIMIT 1;

-- 18. Calcular el total de estadía de los pacientes en hospitales de cada distrito.
SELECT 
  h.distrito, 
  AVG(i.dias_internacion) AS promedio_estadia
FROM hospitales h
INNER JOIN internaciones i ON h.id_hospital = i.id_hospital
GROUP BY h.distrito;

-- 19. Listar los nombres de los hospitales, distritos y la cantidad de camas disponibles que tuvieron internaciones durante el mes de enero del 2022. Incluir todos los hospitales, incluso aquellos sin internaciones registradas.
SELECT DISTINCT 
  h.nombre, 
  COALESCE(h.cantidad_camas, 0) AS camas_disponibles
FROM hospitales h
LEFT JOIN internaciones i ON h.id_hospital = i.id_hospital
WHERE i.fecha BETWEEN '2022-01-01' AND '2022-01-31';

-- 20. Mostrar el nombre y apellido de los pacientes (en un solo campo), el nombre del hospital en el que fueron internados, fecha de internacion, dias de internacion y tipo de egreso
SELECT 
CONCAT(p.nombre,' ',p.apellido) AS paciente, 
h.nombre AS hospital,
i.fecha,
i.dias_internacion,
i.tipo_egreso
FROM pacientes p
INNER JOIN internaciones i ON p.id_paciente = i.id_paciente
INNER JOIN hospitales h ON i.id_hospital = h.id_hospital;

-- 21. Generar un reporte de las internaciones del año 2022 que detalle:
-- ● Nombre del hospital
-- ● Distrito
-- ● Diagnostico (id y nombre en un solo campo)
-- ● Servicio (nombre). En caso de no encontrarlo poner "Sin Especificar"
-- ● Identificador de internacion
-- ● Tipo de egreso
-- ● Dias de internación
SELECT 
  h.nombre AS hospital, 
  h.distrito, concat(d.id_diagnostico,'-',d.diagnostico) AS diagnostico, 
  COALESCE(d.servicio,'Sin Especificar') AS servicio,
  i.id_internacion,
  i.tipo_egreso,
  i.dias_internacion
FROM internaciones i
LEFT JOIN hospitales h ON h.id_hospital = i.id_hospital
LEFT JOIN diagnosticos d ON i.id_diagnostico = d.id_diagnostico;

-- 22. Continuando con el ejercicio anterior, incorporar la descripcion del sector pero en listado solo debe contener las intercaciones del año 2019
SELECT 
  h.nombre AS hospital, 
  h.distrito, concat(d.id_diagnostico,'-',d.diagnostico) AS diagnostico, 
  COALESCE(d.servicio,'Sin Especificar') AS servicio,
  s.sector,
  i.id_internacion,
  i.tipo_egreso,
  i.dias_internacion
FROM internaciones i
LEFT JOIN hospitales h ON h.id_hospital = i.id_hospital
LEFT JOIN diagnosticos d ON i.id_diagnostico = d.id_diagnostico
INNER JOIN sectores s ON s.id_sector=i.id_sector
WHERE YEAR(fecha)=2019;

-- 23. Obener la cantidad de internaciones, promedio de dias de internacion por sexo, distrito y tipo de egreso para los años 2021 y 2022. El listado debe estar ordenado por distrito, tipo de egreso y sexo
SELECT 
  p.sexo,
  h.distrito,
  i.tipo_egreso,
  COUNT(i.id_internacion) AS cantidad_internaciones,
  AVG(i.dias_internacion) AS prom_dias_internacion
FROM internaciones i
INNER JOIN pacientes p ON p.id_paciente=i.id_paciente
INNER JOIN hospitales h ON h.id_hospital=i.id_hospital
WHERE YEAR(i.fecha) IN (2021,2022)
GROUP BY p.sexo, h.distrito, i.tipo_egreso
ORDER BY h.distrito, i.tipo_egreso, p.sexo;

-- 24. Listar el nombre completo de los pacientes que sufrieron traslados. Además del nombre completo el listado debe mostrar:
-- ● fecha de internación
-- ● diagnostico
-- ● servicio
-- ● sector
-- ● dias de internación
-- ● Nota: Normalizar todos los campos que considere
SELECT 
  CONCAT(p.nombre,' ', p.apellido) AS paciente,
  i.fecha AS fecha_internacion,
  initcap(trim(d.diagnostico)) AS diagnostico,
  initcap(trim(d.servicio)) AS servicio,
  initcap(trim(s.sector)) AS sector,
  i.dias_internacion
FROM internaciones i
INNER JOIN diagnosticos d ON d.id_diagnostico = i.id_diagnostico
INNER JOIN pacientes p ON p.id_paciente = i.id_paciente
INNER JOIN sectores s ON s.id_sector = i.id_sector
WHERE i.tipo_egreso = 'Traslado';

-- 25. Calcular la cantidad de pacientes que se internaron en en los años 2020 o 2021 de nacionalidad Argentina y que la edad este entre los 25 y 35 años. Listar la cantidad de pacientes por tipo de egreso.
SELECT i.tipo_egreso, count(DISTINCT i.id_paciente) as cantidad_pacientes
FROM internaciones i
INNER JOIN pacientes p ON p.id_paciente=i.id_paciente
WHERE nacionalidad = 'Argentina' AND edad BETWEEN 25 AND 35
AND YEAR(i.fecha) IN (2020, 2021)
GROUP BY i.tipo_egreso
ORDER BY cantidad_pacientes DESC;

-- 26. ¿A qué distrito pertenece el hospital que mayor cantidad de internaciones durante el mes de Agosto del 2021?
SELECT 
  h.distrito,
  COUNT(i.id_internacion) AS cantidad_internaciones
FROM internaciones i
INNER JOIN hospitales h ON h.id_hospital=h.id_hospital
WHERE i.fecha BETWEEN '2021-08-01' AND '2021-08-31'
GROUP BY h.distrito
ORDER BY cantidad_internaciones DESC
LIMIT 1;

-- 27. Obtener tasa de mortalidad durante el año 2022 considerando que la población estimada para el mismo año para la ciudad de Rosario es de 995.497 habitantes
SELECT 
 (count(id_internacion)/995497)*1000 AS tasa_motalidad
FROM internaciones
WHERE YEAR(fecha)=2022 AND tipo_egreso='Defuncion';

-- 28. Cual es el mayor motivo (diagnóstico) y servicio de las defunciones para todos los años excepto el 2020
SELECT 
  d.servicio,
  d.diagnostico,
  COUNT(i.id_internacion) AS cantidad_internaciones
FROM internaciones i
INNER JOIN diagnosticos d ON d.id_diagnostico=i.id_diagnostico
WHERE YEAR(i.fecha) <> 2020 AND i.tipo_egreso='Defuncion'
GROUP BY d.servicio, d.diagnostico
ORDER BY cantidad_internaciones DESC
LIMIT 1;

-- 29. Calcular el porcentaje de ocupación de camas del hospital Centro de Salud Santa Lucia para el dia 2022-05-23.
-- ● Porcentaje de ocupación = (cantidad de internaciones / cantidad camas disponibles) * 100
SELECT fecha,h.nombre, ((count(id_internacion) / max(h.cantidad_camas))* 100) AS porc_ocupacion
FROM internaciones i
INNER JOIN hospitales h ON i.id_hospital=i.id_hospital
WHERE trim(h.nombre)='Centro de Salud Santa Lucia' AND i.fecha = '2022-05-23'
GROUP BY fecha,h.nombre;

-- 30. Contar la cantidad de diagnosticos distintos por cada servicio. Mostrar sólo aquellos servicios con más de 50 diagnosticos.
SELECT 
  servicio, 
  count(DISTINCT diagnostico) cantidad_diagnosticos
FROM diagnosticos
GROUP BY servicio
HAVING count(DISTINCT diagnostico) > 50;

-- 31. ¿Cuál fue el año con mayor cantidad de internaciones?
SELECT 
  YEAR(fecha) AS anio_internacion,
  count(id_internacion) AS cantidad_internaciones
FROM internaciones
GROUP BY YEAR(fecha)
ORDER BY cantidad_internaciones DESC;

-- 32. Obtener la cantidad de dias de internacion por periodo (año y mes). No se deben tener en cuenta los tipos de egreso Traslado
SELECT 
  YEAR(fecha) AS anio_internacion,
  MONTH(fecha) AS mes_internacion,
  count(id_internacion) AS cantidad_internaciones
FROM internaciones
WHERE tipo_egreso <> 'Traslado'
GROUP BY YEAR(fecha),MONTH(fecha)
ORDER BY cantidad_internaciones DESC;

-- 33. Obtener los distritos que tienen mas de 2000 camas 
SELECT 
  distrito, 
  sum(cantidad_camas) AS total_camas
FROM hospitales
GROUP BY distrito
HAVING total_camas > 2000;

-- 34. Contar la cantidad de pacientes por grupo etario:
-- ● Menos de edad
-- ● Jovenes: entre 18 y 30 años
-- ● Adultos: entre 31 y 60 años
-- ● Adultos Mayores: > 60 años
SELECT
  CASE 
    WHEN edad < 18 THEN 'Menores'
    WHEN edad BETWEEN 18 AND 30 THEN 'Jovenes'
    WHEN edad BETWEEN 31 AND 60 THEN 'Adultos'
  ELSE 'Adultos Mayores'
  END AS grupo_etario,
  count(id_paciente) AS cantidad_pacientes
FROM pacientes
GROUP BY grupo_etario;

-- 35. Mostrar la cantidad de camas disponbiles por distrito. La nueva columna debe tener la leyenda "Cantidad de camas disponibles para el distrito son cantidad_camas". Por ejemplo, La cantidad de camas para el distrito Este son: 2000
-- ● Nota: Tener en cuenta los tipos de datos
SELECT 
  CONCAT('La cantidad de camas disponibles para el ',distrito,' son: ', CAST(sum(cantidad_camas) AS STRING)) AS cantidad_camas
FROM hospitales
GROUP BY distrito;

-- 36. Generar un reporte que cuente la cantidad de internaciones y cantidad de dias de internación en 4 grupos de tipo de internacion.
-- ● Urgente: Son las internaciones donde el servicio contenga la palabra EMERGENCIA
-- ● Infantil: Son las internaciones donde el servicio contenga la palabra PEDIATRIA
-- ● Covid: Son las internaciones donde el servicio contenga la palabra COVID
-- ● Otros: El resto de las internaciones que no pertenezcan a las clasificaciones anteriores
SELECT 
  CASE
    WHEN d.servicio LIKE '%EMERGENCIA%' THEN 'Urgente'
    WHEN d.servicio LIKE '%PEDIATRIA%' THEN 'Infantil'
    WHEN d.servicio LIKE '%COVID%' THEN 'Covid'
    ELSE 'Otros'
  END tipo_internacion,
  count(i.id_internacion) AS cantidad_internaciones,
  SUM(i.dias_internacion) AS dias_internacion
FROM internaciones i
INNER JOIN diagnosticos d ON d.id_diagnostico=i.id_diagnostico
GROUP BY tipo_internacion;

-- 37. Generar un reporte que liste los pacientes de nacionalidad Argentina: El reporte debe contener los campos
-- ● Nombre completo
-- ● sexo
-- ● edad
-- ● fecha de nacimiento
SELECT 
  CONCAT(nombre, ' ',  apellido) AS nombre_completo,
  sexo, 
  edad, 
  date_add(current_date(), -cast(edad*365 AS INT)) AS fecha_nacimiento
FROM pacientes
WHERE nacionalidad = 'Argentina';

-- 38. Generar un informe de las internaciones que se realizaron en el 2020. El mismo debe tener:
-- ● id_internacion
-- ● nombre del hospital
-- ● servicio
-- ● sector
-- ● fecha de ingreso
-- ● fecha de egreso
-- ● cantidad de dias de internacion
-- ● tipo de egreso. Si no tiene un tipo de egreso asignado poner "Sin motivo"
-- ● Nota: Normalizar todos los campos que sean necesarios
SELECT
  i.id_internacion,
  h.nombre AS hospital,
  initcap(TRIM(d.servicio)) as servicio,
  initcap(TRIM(s.sector)) as sector,
  i.fecha AS fecha_ingreso,
  date_add(i.fecha, CAST(i.dias_internacion AS INT)) AS fecha_egreso,
  i.dias_internacion,
  COALESCE(i.tipo_egreso,'Sin motivo') AS tipo_egreso
FROM internaciones i
INNER JOIN hospitales h ON h.id_hospital=i.id_hospital
INNER JOIN diagnosticos d ON d.id_diagnostico=i.id_diagnostico
INNER JOIN sectores s ON s.id_sector=i.id_sector
WHERE YEAR(i.fecha)=2020;

-- 39. Mostrar los nombres de los hospitales que tienen más camas disponibles que el promedio de camas en todos los hospitales. Ademas el reporte debe mostrar:
-- ● Distrito
-- ● Titular
-- ● Cantidad de camas
SELECT 
  nombre,
  distrito,
  titular,
  cantidad_camas
FROM hospitales
WHERE cantidad_camas > (
    SELECT AVG(cantidad_camas)
    FROM hospitales
);

-- 40. Mostrar los hospitales junto con su distrito, cantidad total de camas y promedio de camas en aquellos hospitales que superen el promedio de camas de su respectivo distrito.
SELECT 
  h.nombre,
  h.distrito,
  h.titular,
  h.cantidad_camas,
  s.prom_camas
FROM hospitales h 
INNER JOIN (
            SELECT 
              distrito,
              AVG(cantidad_camas)  AS prom_camas
            FROM hospitales
            GROUP BY distrito
          ) s ON s.distrito=h.distrito
WHERE h.cantidad_camas > s.prom_camas;

-- 41. Crear una vista que muestre los nombres de los pacientes que hayan fallecido en los ultimos 18 meses (tomando en cuenta la fecha de egreso) y que han sido internados en hospitales de tipo "Municipal". Además, el reporte debe tener los siguientes campos:
-- ● Nombre completo
-- ● sexo
-- ● edad
-- ● fecha de nacimiento
-- ● hospital
-- ● distrito
-- ● diagnostico 
-- ● servicio
-- ● cantidad dias internacion
-- ● fecha ingreso
-- ● fecha egreso
-- ● Nota: Normalizar todos los campos que sean necesarios
CREATE OR REPLACE VIEW defunciones_hospitales_municipales AS
SELECT 
  CONCAT(p.nombre,' ', p.apellido) AS nombre_completo,
  sexo,
  edad,
  date_add(current_date(), -cast(edad*365 AS INT)) AS fecha_nacimiento,
  TRIM(h.nombre) AS hospital,
  INITCAP(TRIM(h.distrito)) AS distrito,
  INITCAP(TRIM(d.servicio)) AS servicio,
  INITCAP(TRIM(d.diagnostico)) AS diagnostico,
  i.dias_internacion,
  i.fecha AS fecha_ingreso,
  date_add(i.fecha, CAST(i.dias_internacion AS INT)) AS fecha_egreso
FROM pacientes p
INNER JOIN internaciones i ON (i.id_paciente=p.id_paciente)
INNER JOIN hospitales h ON (h.id_hospital=i.id_hospital)
INNER JOIN diagnosticos d ON (d.id_diagnostico=i.id_diagnostico)
WHERE h.titular = 'Municipal' AND i.tipo_egreso='Defuncion'
AND date_add(i.fecha, CAST(i.dias_internacion AS INT)) >  date_add(current_date(),-18*30);

-- 42. Crear una vista del enunciado numero 40
CREATE OR REPLACE VIEW vista_hospitales_mas_camas_promedio AS
SELECT 
  h.nombre,
  h.distrito,
  h.titular,
  h.cantidad_camas,
  s.prom_camas
FROM hospitales h 
INNER JOIN (
            SELECT 
              distrito,
              AVG(cantidad_camas)  AS prom_camas
            FROM hospitales
            GROUP BY distrito
          ) s ON s.distrito=h.distrito
WHERE h.cantidad_camas > s.prom_camas;

-- 43. Listar los nombres de los hospitales y el número de internaciones por cada tipo de servicio realizadas en los últimos 2 años
SELECT 
  h.nombre AS hospital,
  d.servicio,
  COUNT(i.id_internacion) AS cantidad_internaciones
FROM hospitales h
LEFT JOIN internaciones i ON h.id_hospital = i.id_hospital
INNER JOIN diagnosticos d ON d.id_diagnostico=i.id_diagnostico
WHERE i.fecha >= DATEADD(YEAR, -2, CURRENT_DATE())
GROUP BY h.nombre, d.servicio;

-- 44. Obtener los nombres de los hospitales y el promedio de edad de los pacientes internados en cada hospital
SELECT h.nombre AS hospital, 
       COALESCE(AVG(p.edad), 0) AS promedio_edad_pacientes
FROM hospitales h
LEFT JOIN internaciones i ON h.id_hospital = i.id_hospital
LEFT JOIN pacientes p ON i.id_paciente = p.id_paciente
GROUP BY h.nombre;

-- 45. Obtener un listado de hospitales que muestre la cantidad minima, maxima y promedio de internacion por año. Ordenar el resultado por hospital y año de manera ascendente.
SELECT
  trim(h.nombre) AS hospital,
  extract(YEAR from fecha) AS anio_internacion,
  min(dias_internacion) AS min_dias_internacion,
  max(dias_internacion) AS max_dias_internacion,
  avg(dias_internacion) AS prom_dias_internacion
FROM internaciones i
INNER JOIN hospitales h ON h.id_hospital=h.id_hospital
GROUP BY h.nombre,extract(YEAR from fecha) 
ORDER BY h.nombre,extract(YEAR from fecha) ASC;
