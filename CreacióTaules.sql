--Pol Hernàndez, Xavier Moreno, Ariadna Pascual

--1. Plantejament de l'estructura de la taula

/**/

--1. Taula que rebrà les dades del fitxer

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