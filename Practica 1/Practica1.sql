/*  Práctica 1: Repaso de programación de consultas en BD Relacionales 

Instrucciones: Considerando la BD escuela, programe las siguientes consultas y rutinas. Puede utilizar vistas si la solución lo requiere.
Objetivo: Ejercitar la instrucción SELECT con sus diversas clausulas (INNER JOIN, LEFT JOIN, IN, EXIST, GROUP BY, entre otras)
          aplicando el menor número de operaciones posible para resolver las consultas.  
Fecha de entrega: viernes 18 de febrero a más tardar 11:30 pm
Modalidad: individual
*/
use escuela;
/* Consultas a resolver 
-- insertar 5 tuplas adicionales en curso_has_estudiante
-- 1: Listar los alumnos con estatus de regular (considere que un alumno regular puede tener no aprobada como máximo una materia)
-- 2: Listar el porcentaje de no aprobados por materia en los semestres 20212 y 20221 
-- 3: Listar los profesores que aprobaron a todos sus alumnos en todas sus materias
-- 4: Listar los profesores con el mayor porcentaje de no aprobados en los semestres 20212 y 20221
-- 5: Determinar si en la materia T302 existe un porcentaje de no aprobados entre el 30% y 50% en cada uno de sus grupos.
-- 6: Listar los alumnos que han aprobado todas las asignaturas que imparte el profesor  10275287
*/
-- 0
INSERT INTO `escuela`.`curso_has_estudiante` (`semestre`, `grupo`, `idMateria`, `idEstudiante`, `calificacion`) VALUES ('20212', '2TM5', 'T203', '2018641025', '9'); -- Grupo y idMateria deben existir.
INSERT INTO `escuela`.`curso_has_estudiante` (`semestre`, `grupo`, `idMateria`, `idEstudiante`, `calificacion`) VALUES ('20221', '4TM5', 'T410', '2019640011', '8'); -- Ademas idEstudiante debe existir 
INSERT INTO `escuela`.`curso_has_estudiante` (`semestre`, `grupo`, `idMateria`, `idEstudiante`, `calificacion`) VALUES ('20211', '3TM1', 'T302', '2019641134', '7'); -- y no debe ser alguien que ya la inscribio.
INSERT INTO `escuela`.`curso_has_estudiante` (`semestre`, `grupo`, `idMateria`, `idEstudiante`, `calificacion`) VALUES ('20222', '4TM3', 'T410', '2019640231', '5');
INSERT INTO `escuela`.`curso_has_estudiante` (`semestre`, `grupo`, `idMateria`, `idEstudiante`, `calificacion`) VALUES ('20212', '2TV3', 'T203', '2019640011', '3');
UPDATE `escuela`.`curso_has_estudiante` SET `calificacion` = '6' WHERE (`semestre` = '20222') and (`grupo` = '4TM3') and (`idMateria` = 'T410') and (`idEstudiante` = '2019640231');
select * from curso;
select * from curso_has_estudiante;
select * from estudiante;
select * from materia;
select * from profesor;
-- 1: Listar los alumnos con estatus de regular (considere que un alumno regular puede tener no aprobada como máximo una materia)

-- Todos los alumnos con sus respectivas calificiones.
select * from curso_has_estudiante;

-- Todos los alumnos con calificaciones reprobatorias.
select * 
from curso_has_estudiante
where calificacion < 6;

-- Alumnos con su cantidad de calificciones reprobatorias.
select idEstudiante, count(*) 
from curso_has_estudiante
where calificacion < 6
group by idEstudiante;

-- Alumnos que tienen una sola materia reprobada.
select idEstudiante, count(*) 
from curso_has_estudiante
where calificacion < 6
group by idEstudiante
having count(*) = 1;

-- Respuesta
CREATE VIEW 
Alumnos_Reprobados AS 
select idEstudiante, count(*) as "Cantidad_Reprobadas"
from curso_has_estudiante
where calificacion < 6
group by idEstudiante;

select distinct(idEstudiante) 
from 
curso_has_estudiante
where idEstudiante not in (select idEstudiante
						from Alumnos_Reprobados
						where Cantidad_Reprobadas >= 2) and calificacion between 6 and 10;

-- 2: Listar el porcentaje de no aprobados por materia en los semestres 20212 y 20221 

-- Numero de Todos los alumnos reprobados por materia en los semestres 20212 y 20221 
select idMateria, count(*)
from curso_has_estudiante
where calificacion <6 and semestre like "2021_"
group by idMateria;

-- Numero de Todos los alumnos en los semestres 20212 y 20221 
select count(*) as "Total_Alumnos"
from curso_has_estudiante
where semestre like "2021_";

-- Respuesta.
select idMateria, count(*) /  (select count(*) 
							  from curso_has_estudiante
							  where semestre like "2021_") as "Porcentaje Alumnos reprobados "
from curso_has_estudiante
where calificacion <6 and semestre like "2021_"
group by idMateria;

-- 3: Listar los profesores que aprobaron a todos sus alumnos en todas sus materias

-- Todos los alumnos con sus respectivos profesores. 
select * 
from curso cu inner join curso_has_estudiante cuhas
on cu.idMateria=cuhas.idMateria and cu.grupo=cuhas.grupo;

-- Todos los alumnos reprobados con sus respectivos profesores. 
select *
from curso cu inner join curso_has_estudiante cuhas
on cu.idMateria=cuhas.idMateria and cu.grupo=cuhas.grupo
where calificacion <6;

-- Todos los profesores que han reprobado.
select distinct(idProfesor)
from curso cu inner join curso_has_estudiante cuhas
on cu.idMateria=cuhas.idMateria and cu.grupo=cuhas.grupo
where calificacion <6;

-- Respuesta.
select distinct(idProfesor) from curso
where idProfesor  not in (select distinct(idProfesor)
						from curso cu inner join curso_has_estudiante cuhas
						on cu.idMateria=cuhas.idMateria and cu.grupo=cuhas.grupo
						where calificacion <6);

-- 4: Listar los profesores con el mayor porcentaje de no aprobados en los semestres 20212 y 20221

-- Todos los alumnos reprobados de los semstres 20212 y 20221.
select * 
from curso cu inner join curso_has_estudiante cuhas
on cu.idMateria=cuhas.idMateria and cu.grupo=cuhas.grupo and cu.Semestre like "2021_" and calificacion <6;

-- Numero de alumnos reprobados de los semstres 20212 y 20221 por profesor.
select cu.idProfesor, count(*) as "Total_Alumnos_Reprobados"
from curso cu inner join curso_has_estudiante cuhas
on cu.idMateria=cuhas.idMateria and cu.grupo=cuhas.grupo and cu.Semestre like "2021_" and calificacion <6
group by cu.idProfesor;

-- Numero total de alumnos de los semstres 20212 y 20221.
select count(*) as "Total_Alumnos"
from curso cu inner join curso_has_estudiante cuhas
on cu.idMateria=cuhas.idMateria and cu.grupo=cuhas.grupo and cu.Semestre like "2021_";

-- Respuesta.
select cu.idProfesor, count(*)*100/(select count(*) 
					from curso cu inner join curso_has_estudiante cuhas
					on cu.idMateria=cuhas.idMateria and cu.grupo=cuhas.grupo and cu.Semestre like "2021_") as "Indice_Reprobados_En_20211-20212"
                    from curso cu inner join curso_has_estudiante cuhas
					on cu.idMateria=cuhas.idMateria and cu.grupo=cuhas.grupo and cu.Semestre like "2021_" and calificacion <6
					group by cu.idProfesor
                    order by 2 desc;

-- 5: Determinar si en la materia T302 existe un porcentaje de no aprobados entre el 30% y 50% en cada uno de sus grupos.

 -- Total alumnos de materia T302
select count(*) 
from curso_has_estudiante
where idMateria="T302";

 -- Total alumnos reprobados de materia T302
select * 
from curso_has_estudiante
where idMateria="T302" and calificacion < 6;

 -- Total alumnos reprobados por grupo de materia T302
select grupo, count(*) as "Numero_Reprobados_x_Grupo"
from curso_has_estudiante
where idMateria="T302" and calificacion < 6
group by grupo;

-- Porcentaje de Reprobados por grupo.
select grupo, count(*)*100/(select count(*) 
							from curso_has_estudiante
							where idMateria="T302") as "Porcentaje de Reprobados"
                            from curso_has_estudiante
							where idMateria="T302" and calificacion < 6
							group by grupo;

-- Respuesta.
select grupo, count(*)*100/(select count(*) 
							from curso_has_estudiante
							where idMateria="T302") as "Porcentaje_de_Reprobados"
from curso_has_estudiante
where idMateria="T302" and calificacion < 6
group by grupo
having "Porcentaje_de_Reprobados" between 30 and 50;


-- 6: Listar los alumnos que han aprobado todas las asignaturas que imparte el profesor  10275287
select * from curso_has_estudiante;
select * from curso;

-- Todos los alumnos de 10275287
select * 
from curso cu inner join curso_has_estudiante cuhas
on cu.idMateria=cuhas.idMateria and cu.grupo=cuhas.grupo and idProfesor=10275287;

-- Todos los alumnos reprobados de 10275287
select * 
from curso cu inner join curso_has_estudiante cuhas
on cu.idMateria=cuhas.idMateria and cu.grupo=cuhas.grupo and idProfesor=10275287 and calificacion < 6;

-- Respuesta.
select * 
from curso cu inner join curso_has_estudiante cuhas
on cu.idMateria=cuhas.idMateria and cu.grupo=cuhas.grupo and idProfesor=10275287
where idEstudiante not in (select distinct(idEstudiante) 
						  from curso cu inner join curso_has_estudiante cuhas
						  on cu.idMateria=cuhas.idMateria and cu.grupo=cuhas.grupo and idProfesor=10275287 and calificacion < 6);

