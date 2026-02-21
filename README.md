# SQL-Salud-Rosario
Práctica de SQL sobre Databricks. Enunciados brindados por la empresa Lovelytics.

## 🏥 Sobre el Proyecto
Este repositorio contiene un análisis técnico y de negocio basado en los datos de **Salud Pública de la Ciudad de Rosario, Santa Fe**. El objetivo es transformar registros de internaciones, pacientes y hospitales en información valiosa para la toma de decisiones en gestión sanitaria y eficiencia hospitalaria.

El proyecto utiliza **SQL (Databricks / Spark SQL)** para resolver desafíos reales del sector, estructurados en tres niveles de complejidad incremental.

## 📊 El Modelo de Negocio


![DER-Salud](https://github.com/user-attachments/assets/ef09e471-0a1c-4f2d-bd6b-682a5367e048)

El análisis se centra en la capacidad operativa, la demanda de servicios y la demografía de la población atendida. El esquema de datos incluye:

* **Pacientes:** Perfiles demográficos (edad, sexo, nacionalidad).
* **Hospitales:** Infraestructura, capacidad de camas y ubicación por distritos.
* **Internaciones:** Registro de ingresos, días de estadía, motivos de egreso y diagnósticos.
* **Diagnósticos y Sectores:** Clasificación médica y áreas específicas de atención.

## 🛠️ Soluciones y Consultas SQL
Las consultas están organizadas en etapas para demostrar diferentes habilidades analíticas:

### 🔹 Nivel 1: Fundamentos y Limpieza de Datos
* Filtrado de instituciones según administración (Provincial vs. Municipal).
* Cálculo de métricas base como promedios de internación y conteos por diagnóstico.
* Tratamiento de valores nulos con `COALESCE` para reportes de gestión.

### 🔹 Nivel 2: Análisis Relacional (Joins y Agregaciones)
* **Gestión de Capacidad:** Análisis de disponibilidad de camas por distrito durante periodos críticos.
* **Productividad por Servicio:** Identificación de áreas con alta diversidad diagnóstica (>50 tipos distintos).
* **Tendencias Temporales:** Identificación de años pico y análisis de estacionalidad mensual.

### 🔹 Nivel 3: Lógica de Negocio Avanzada
* **Segmentación Etaria:** Clasificación de pacientes mediante `CASE WHEN` (Menores, Jóvenes, Adultos, Adultos Mayores).
* **Análisis de Criticidad:** Clasificación de internaciones en "Urgentes" o "Programadas" según el motivo de ingreso.
* **KPIs de Gestión:** Reportes consolidados que cruzan edad promedio, capacidad instalada y estadía media por centro de salud.

## 🚀 Tecnologías Utilizadas
* **Motor:** SQL / Spark SQL.
* **Plataforma:** Databricks.
* **Fuente de Datos:** [Portal de Datos Abiertos de la Municipalidad de Rosario](https://datos.rosario.gob.ar/).
