USE CampeonatosFIFA
GO
SELECT * FROM Pais

/* -- Adicionar campo -- */

ALTER TABLE Pais
ADD Capital VARCHAR(100);

/* -- Eliminar campo -- */

ALTER TABLE Pais
DROP COLUMN Capital;


/* -- Adcionar clave for�nea --*/

ALTER TABLE Ciudad
ADD CONSTRAINT fkCiudad_IdPais
FOREIGN KEY (IdPais) REFERENCES Pais(Id);

/* -- Adicionar CONSTRAINT con CHECK -- */
/* -- Ejemplo 1. Validar que el a�o de un campeonato sea mayor a 1900 -- */
ALTER TABLE Campeonato
ADD CONSTRAINT CK_Campeonato_A�o
CHECK (A�o >= 1900);	-- lo que hace es impedir que se inserten o actualicen registros que no cumplan la condici�n.

/* -- Emjemplo 2. 	Validar que los goles en un encuentro no sean negativos -- */
ALTER TABLE Encuentro
ADD CONSTRAINT CK_Encuentro_Goles
CHECK (Goles1 >= 0 AND Goles2 >= 0);	-- los goles no pueden ser valores negativos

UPDATE Encuentro
SET Goles1 = -2,
    Goles2 = -1
WHERE Id = 6;

/*--------- Usar el procedimiento SP_RENAME para cambiar el nombre de una tabla--------------------- */
-- Cuando cambiamos el nombre de una tabla con SP_RENAME, SQL Server se encarga autom�ticamente de	--
-- actualizar las referencias internas a esa tabla, incluidas las claves for�neas. Ni  cambiar nada --
-- manualmente en tus constraints. Ellos se ajustan autom�ticamente.								--

EXEC sp_rename 'Encuentro', 'Enfrentamiento';

/* -- Cree un �ndice por c�digo adicional en una de las tablas	   --*/	
/* -- y explique la diferencia entre �ndice agrupado y no agrupado --*/

-- Para este caso escogeremos por ejemplo acelerar consultas por a�o, 
-- en la tabla Campeonato

CREATE NONCLUSTERED INDEX ixCampeonato_A�o	-- Estes �ndice es no agrupado
ON Campeonato(A�o);

-- Podemos ver todos los �ndices de la tabla Campeonato

EXEC sp_helpindex 'Campeonato';


--------------------------------------------------------
-- Diferencias entre �ndice agrupado  y no agrupado:  --
-- _____________________________________________________
-- INDICES AGRUPADOS:
-- * Ordena las filas de la tabla seg�n la clave del �ndice. 
-- * Solo puede haber uno por tabla
-- * Se usa en consultas en rangos claves primarias o columnas
-- * Eficiente en columnas que necesitan recorrer rangos
-- INDICES NO AGRUPADOS:
-- * Crea una estructura separada  que apunta a las filas
-- * Pueden haber varios por tabla.
-- * Se puede usar en columnas usadas en b�squedas frecuentes
-- * B�squedas puntuales o combinaciones de columnas

/*********************************************/
-- 2. Operaciones con relaciones y l�gicos . --

SELECT c.Campeonato, p.Pais, c.A�o						-- Relacionamos Campeonato con Pais usando la condici�n c.IdPais = p.Id.
FROM Campeonato c, Pais p
WHERE c.IdPais = p.Id AND c.A�o BETWEEN 2000 AND 2010;	-- se filtran los campeonatos cuyo a�o est� entre 2000 y 2010.

SELECT * FROM Estadio
WHERE (Capacidad BETWEEN 20000 AND 40000)				-- Escogemos capacidades entre 20000 y 40000 � entre 50000 y 
   OR (Capacidad BETWEEN 50000 AND 80000 AND NOT Capacidad = 70000); -- 80000 y no exactamente 70000

-- 2 consultas con is null pag 62 --

-- Para encontrar registros nulos --
SELECT * FROM Pais WHERE Bandera IS NULL;

-- Para encontrar registros NO nulos --
SELECT * FROM Pais WHERE Entidad IS NOT NULL;

-- 2 consultas de left join o righ join --
/* Estadios incluso sin ciudad asociada */
SELECT e.Estadio, e.Capacidad, c.Ciudad
FROM Estadio AS e
LEFT JOIN Ciudad AS c
ON e.IdCiudad = c.Id; -- Esta instrucci�n me devuelve todos los estadios, incluso si no tienen ciudad asociada

/* Ciudades incluso sin estadio y donde la capacidad es null */
SELECT e.Estadio, e.Capacidad, c.Ciudad
FROM Estadio AS e
RIGHT JOIN Ciudad AS c
ON e.IdCiudad = c.Id WHERE Capacidad IS NULL; -- Esta instruccion me devuelve las ciudades que incluso no tienen estadio asociados
											  -- d�nde Capacidad es null... tambien si quitamos el where quedar� una tabla m�s amplia 

-- 2 consultas de agrupamiento con group by y con having --
/* Contamos estadios por ciudad */
SELECT c.Ciudad,					-- De ciudad escogemos
COUNT (e.Estadio) AS TotalEstadios	-- Cuenta el total de estadios por ciudad
FROM Estadio e, Ciudad c			
WHERE e.IdCiudad = c.Id				 
GROUP BY c.Ciudad					-- Ac� se agrupan todos los estadios por ciudad
HAVING COUNT(e.Estadio) > 1;		-- filtra los grupos y muestra solo las ciudades con m�s de un estadio

/* Promedio de capacidad por ciudad */
SELECT c.Ciudad, AVG(e.Capacidad) AS PromedioCapacidad -- calcula el promedio de capacidad de los estadios en cada ciudad.
FROM Estadio e, Ciudad c
WHERE e.IdCiudad = c.Id								   -- El WHERE filtra filas antes de agrupar
GROUP BY c.Ciudad
HAVING AVG(e.Capacidad) >30000;						   -- muestra solo las ciudades cuyo promedio de capacidad supera los 30 mil asientos.	

-- Realizar 4 subconsultas con IN, NOT IN --
/* Listar estadios en ciudades espec�ficas */
SELECT e.Estadio, e.Capacidad
FROM Estadio e
WHERE e.IdCiudad IN(SELECT c.Id FROM Ciudad c WHERE c.Ciudad IN ('Medell�n', 'Bogot�', 'Cali'));

/* Listar campeonatos quess se jugaron en estadios con capacidad mayor a 40000 */
SELECT c.Campeonato, c.A�o
FROM Campeonato c
WHERE c.Id IN(SELECT e.Id FROM Estadio e WHERE e.Capacidad > 40000);

/* Listar ciudades que no tienen estadios registrados */
SELECT c.Ciudad
FROM Ciudad c
WHERE c.Id NOT IN (SELECT e.Id FROM Estadio e);

/* Listar campeonatos que no se jugaron en 2020 ni 2022 */
SELECT c.Campeonato, c.A�o
FROM Campeonato c
WHERE c.Id NOT IN (SELECT A�o FROM Campeonato WHERE A�o IN (2020, 2022));

/* -- 3. Investigar estas instrucciones UNION, INTERSECT, EXCEPT (p�gina 70) LOWER, UPPER, GETDATE, DAY, MONTH, YEAR, DATEDIF,  
---- Algunas de las funciones matem�ticas ABS, RAND, SQRT, POWER, La funci�n SUBSTRING, la funci�n CONCAT y
---- la funci�n CAST, y La sentencia TOP, DISTINCT, y hacer ejemplos de cada uno con consultas select */

/* SELECT con UNION*/ 
SELECT Ciudad, Id	-- Ac� tenemos ciudades con su Id de Ciudad
FROM Ciudad
UNION				-- El UNION combina el resultado de arriba y el de abajo
SELECT Estadio, Id	-- En esta parte los estadios con Id de Ciudad
FROM Estadio;

/* SELECT con INTERSECT */ 
SELECT IdPais
FROM Campeonato	-- Esta consulta devuelve los pa�ses que participan en campeonatos.
INTERSECT		-- El INTERSECT devuelve solo los pa�ses que cumplen ambas condiciones.
SELECT IdPais	-- Esta  consulta devuelve los pa�ses que tienen ciudades registradas.
FROM Ciudad;	-- Devuelve la lista de IdPais que aparecen tanto en la tabla Campeonato como en la tabla Ciudad.

/* SELECT con EXCEPT */
SELECT IdPais	-- La consulta devuelve todos los pa�ses que participan en campeonatos.
FROM Campeonato
EXCEPT			-- El  devuelve �nicamente los pa�ses que aparecen en Campeonato pero no en Ciudad.
SELECT IdPais	-- La consulta devuelve los pa�ses que tienen ciudades registradas.
FROM Ciudad;

/* ejmplo UPPER  and LOWER */
SELECT LOWER(Pais) AS PaisMinuscula, UPPER(Entidad) AS EntidadMayuscula
FROM Pais;		-- Se hace una consulta y se crean tablas que pone el contenido en min�scula o ma�scula

/* Ejemplo GETDATE, DAY, MONTH, YEAR */
SELECT
	GETDATE() AS FechaCompleta,
	YEAR(GETDATE()) AS A�oActual,
	MONTH(GETDATE()) AS MesActual,
	DAY(GETDATE()) AS DiaActual;

/* Ejemplo DATEDIFF */
SELECT DATEDIFF(DAY,'2025-10-31','2026-03-18') AS DiasDiferencia;

/* Ejemlo Math ABS */
SELECT ABS(-18) AS ValorAbsoluto;

/* Ejemplo Math RAND */
SELECT RAND() AS NumeroAleatorio;

/* Ejemplo Math SQRT */
SELECT SQRT(36)  AS RaizCuadrada;

/* Ejemplo Math POWER */
SELECT POWER(4,3) AS Potencia;

/* Ejemplo funci�n SUBSTRING */
SELECT Ciudad, SUBSTRING(Ciudad, 2,3) AS ParteCiudad	-- Apartir de las segunda letra toma tres caracteres del campo Ciudad en la tabla Ciudad
FROM Ciudad;

/* Ejemplo funci�n CONCAT */
SELECT CONCAT (Campeonato,'',A�o) AS Fusion	-- Concatena los campos Campeonato con A�o.
FROM Campeonato;

/* Ejemplo CAST */ 
SELECT CAST(Capacidad AS decimal(10,1)) FROM Estadio;

/* Ejemplo TOP */ 
SELECT TOP 6* 
FROM  Campeonato
ORDER BY A�o;

/* Ejemplo DISTINCT */
SELECT DISTINCT Entidad
FROM Pais;

--4.2 vistas utilizando m�nimo 3 inner join con agrupamiento y con where
-- Esta vista muestra un resumen de grupos por campeonato, contando el total de pa�ses en cada grupo, filtrando solo el grupo A.
/* Vistas con GROUP BY */
CREATE VIEW vw_ResumenGrupos AS
SELECT c.Campeonato,g.Grupo,  
    COUNT(p.Id) AS TotalPaises                    -- Cuenta el total de pa�ses en cada grupo, utilizando el campo Id de la tabla Pais.
FROM GrupoPais gp
INNER JOIN Grupo g ON gp.IdGrupo = g.Id           -- Relaciona la tabla GrupoPais con Grupo usando el campo IdGrupo.
INNER JOIN Campeonato c ON g.IdCampeonato = c.Id  -- Relaciona la tabla Grupo con Campeonato usando el campo IdCampeonato.
INNER JOIN Pais p ON gp.IdPais = p.Id             -- Relaciona la tabla GrupoPais con Pais usando el campo IdPais.
WHERE g.Grupo = 'A'                               -- Filtra los resultados para incluir solo el grupo A.
GROUP BY c.Campeonato , g.Grupo;                  -- Agrupa los resultados por campeonato y grupo, y cuenta el total de pa�ses en cada grupo.

SELECT * FROM vw_ResumenGrupos
WHERE Grupo = 'A';

-- Esta vista muestra un resumen de enfrentamientos por campeonato, a�o y fase, contando el total de enfrentamientos para cada combinaci�n.
/* Vistas con GROUP BY */
CREATE VIEW vw_ResumenEnfrentamientos AS --crea una vista llamada vw_ResumenEnfrentamientos que muestra un resumen de enfrentamientos por campeonato.
SELECT c.Campeonato, c.A�o,	f.Fase,       
    COUNT(e.Id) AS TotalEnfrentamientos             
FROM Enfrentamiento e
INNER JOIN Campeonato c ON e.IdCampeonato = c.Id    -- Relaciona la tabla Enfrentamiento con Campeonato usando el campo IdCampeonato.
INNER JOIN Fase f ON e.IdFase = f.Id                -- Relaciona la tabla Enfrentamiento con Fase usando el campo IdFase.
INNER JOIN Estadio s ON e.IdEstadio = s.Id          -- Relaciona la tabla Enfrentamiento con Estadio usando el campo IdEstadio.
INNER JOIN Pais p ON e.IdPais1 = p.Id               -- Relaciona la tabla Enfrentamiento con Pais usando el campo IdPais1.
WHERE c.A�o >= 1990                                 -- Filtra los enfrentamientos para incluir solo aquellos que ocurrieron a partir del a�o 1990.
GROUP BY c.Campeonato , c.A�o, f.Fase ;             -- Agrupa los resultados por campeonato, a�o y fase, y cuenta el total de enfrentamientos para cada combinaci�n.

SELECT  * FROM vw_ResumenEnfrentamientos;

--2 vistas utilizando m�nimo 3 inner join con agrupamiento y con having
/* Vistas con HAVING */
-- Esta vista muestra un resumen de estadios por pa�s y campeonato, contando el total de estadios para cada combinaci�n, filtrando solo aquellos con m�s de un estadio.
CREATE VIEW vw_ResumenEstadios AS
SELECT 
    p.Pais,              
    h.Campeonato ,              
    COUNT(e.Id) AS TotalEstadios
FROM Estadio e
INNER JOIN Ciudad c ON e.IdCiudad = c.Id             -- Relaciona la tabla Estadio con Ciudad usando el campo IdCiudad.
INNER JOIN Pais p ON c.IdPais = p.Id                 -- Relaciona la tabla Ciudad con Pais usando el campo IdPais.
INNER JOIN Campeonato h ON p.Id = h.IdPais           -- Relaciona la tabla Pais con Campeonato usando el campo IdPais.
GROUP BY p.Pais , h.Campeonato                       -- Agrupa los resultados por pa�s y campeonato, y cuenta el total de estadios para cada combinaci�n.      
HAVING COUNT(e.Id) > 1 ;                             -- Filtra los grupos y muestra solo aquellos pa�ses y campeonatos que tienen m�s de un estadio asociado.

SELECT * FROM vw_ResumenEstadios;

/* Vistas con HAVING */
-- Esta vista muestra un resumen de campeonatos por fase, contando el total de enfrentamientos para cada combinaci�n, filtrando solo aquellos con al menos un estadio asociado.
CREATE VIEW vw_CampeonatosResumen AS
SELECT 
    c.Campeonato,              
    f.Fase,              
    COUNT(e.Id) AS TotalEncuentros
FROM Enfrentamiento e
INNER JOIN Campeonato c ON e.IdCampeonato = c.Id  -- Relaciona la tabla Enfrentamiento con Campeonato usando el campo IdCampeonato.
INNER JOIN Fase f ON e.IdFase = f.Id              -- Relaciona la tabla Enfrentamiento con Fase usando el campo IdFase.
INNER JOIN Estadio s ON e.IdEstadio = s.Id        -- Relaciona la tabla Enfrentamiento con Estadio usando el campo IdEstadio.
INNER JOIN Pais p ON e.IdPais1 = p.Id             -- Relaciona la tabla Enfrentamiento con Pais usando el campo IdPais1.
GROUP BY c.Campeonato , f.Fase                    -- Agrupa los resultados por campeonato y fase, y cuenta el total de enfrentamientos para cada combinaci�n.
HAVING COUNT(s.Id) >= 1 ;                         -- Filtra los grupos y muestra solo aquellos campeonatos y fases que tienen al menos un estadio asociado.

SELECT * FROM vw_CampeonatosResumen;


-- Crear tabla temporal con ciudades y estadios por pa�s
SELECT 
    p.Pais,
    c.Ciudad,
    e.Estadio,
    e.Capacidad                             -- Selecciona el pa�s, ciudad, estadio y capacidad de los estadios.
INTO #TempCiudadesEstadios                  --  Crea una tabla temporal
FROM Estadio e
INNER JOIN Ciudad c ON e.IdCiudad = c.Id    --  Relaciona la tabla Estadio con Ciudad usando el campo IdCiudad.
INNER JOIN Pais p ON c.IdPais = p.Id;       --  Relaciona la tabla Ciudad con Pais usando el campo IdPais.

-- Consultar la tabla temporal
SELECT * FROM #TempCiudadesEstadios;


