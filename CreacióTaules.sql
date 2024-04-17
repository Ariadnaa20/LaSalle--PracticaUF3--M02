--Pol Hernàndez, Xavier Moreno, Ariadna Pascual

--PAS 1:

--1. Plantejament de l'estructura de la taula

/* Hem decidit estructurar la taula d'aquesta manera per diverses raons. En primer lloc, hem optat per utilitzar una clau primària autoincremental per a la columna id per proporcionar una identificació única per a cada registre de log. Això facilita la gestió de les dades i les operacions de consulta.

En segon lloc, hem separar la data i l'hora en columnes independents (Fecha i Hora) perquè ens permet gestionar de manera més flexible les dades i facilita les consultes que necessiten filtrar per data, hora o intervals de temps específics.

Quant a les columnes Sistema, Origen i Mensaje, les hem seleccionades per reflectir els components més rellevants dels registres de log. Utilitzar el tipus de dada VARCHAR per a aquestes columnes ens proporciona una estructura flexible i adaptable als tipus de dades que esperem emmagatzemar.

Finalment, hem triat utilitzar el tipus de dada TEXT per a la columna Mensaje per acomodar missatges de log de longitud variable. Això ens permet emmagatzemar missatges de log de qualsevol mida sense preocupar-nos per restriccions de longitud.*/


--2. Taula que rebrà les dades del fitxer

USE DBPractica;

DROP TABLE IF EXISTS CarregarLogs;

CREATE TABLE IF NOT EXISTS CarregarLogs (
	id INT AUTO_INCREMENT,
    Fecha DATE,
    Hora TIME,
    Sistema VARCHAR(50),
    Origen VARCHAR(50),
    Mensaje VARCHAR(255),
    PRIMARY KEY (id)
);



--3. Codi encarregat de carregar aquest fitxer

DELIMITER &&

DROP EVENT IF EXISTS ImportarDades &&

CREATE EVENT IF NOT EXISTS ImportarDades
ON SCHEDULE EVERY 1 DAY 
STARTS '2024-04-08 23:59:59'
DO
    BEGIN
        SET @file_path = CONCAT('/home/elon/syslog_', YEAR(NOW()), '-', LPAD(MONTH(NOW()), 2, '0'), '-', LPAD(DAY(NOW()), 2, '0'));
        SET @load_query = CONCAT('LOAD DATA INFILE ', QUOTE(@file_path), ' INTO TABLE CarregarLogs FIELDS TERMINATED BY ";" ENCLOSED BY \'""\' LINES TERMINATED BY "\n";');
        PREPARE stmt FROM @load_query;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END &&

DELIMITER ;


--PAS 2

-- 2.1 Creació de taules de control 

-- Taula per al registre dels fitxers carregats cada dia
CREATE TABLE IF NOT EXISTS RegistreFitxers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom_fitxer VARCHAR(255),
    data_càrrega DATETIME
);

-- Taula per al registre del nombre de files inserides per cada fitxer
CREATE TABLE IF NOT EXISTS NombreFilesInserides (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom_fitxer VARCHAR(255),
    num_files_inserides INT,
    data_càrrega DATETIME
);


-- 2.2 Procés de tractament dels fitxers syslog 

-- Obtenció del fitxer del dia anterior
SET @fitxer_dia_anterior = CONCAT('/home/elon/syslog_', YEAR(NOW() - INTERVAL 1 DAY), '-', LPAD(MONTH(NOW() - INTERVAL 1 DAY), 2, '0'), '-', LPAD(DAY(NOW() - INTERVAL 1 DAY), 2, '0'));

-- Inserció del registre del fitxer carregat cada dia
INSERT INTO RegistreFitxers (nom_fitxer, data_càrrega) VALUES (@fitxer_dia_anterior, NOW());

-- Inserció del nombre de files inserides per al fitxer del dia anterior
SET @num_files_inserides = (SELECT COUNT(*) FROM CarregarLogs WHERE Fecha = DATE(NOW() - INTERVAL 1 DAY));
INSERT INTO NombreFilesInserides (nom_fitxer, num_files_inserides, data_càrrega) VALUES (@fitxer_dia_anterior, @num_files_inserides, NOW());



