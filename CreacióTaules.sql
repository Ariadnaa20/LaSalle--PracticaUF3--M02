--Pol Hernàndez, Xavier Moreno, Ariadna Pascual

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