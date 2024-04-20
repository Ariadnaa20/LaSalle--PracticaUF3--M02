--Pol Hernàndez, Xavier Moreno, Ariadna Pascual

--PAS 1: CÀRREGA DE FITXERS

--1.1 Plantejament de l'estructura de la taula

/* Hem decidit estructurar la taula d'aquesta manera per diverses raons. En primer lloc, hem optat per utilitzar una clau primària autoincremental per a la columna id per proporcionar una identificació única per a cada registre de log. Això facilita la gestió de les dades i les operacions de consulta.

En segon lloc, hem separar la data i l'hora en columnes independents (Fecha i Hora) perquè ens permet gestionar de manera més flexible les dades i facilita les consultes que necessiten filtrar per data, hora o intervals de temps específics tal com vem fer a Sistemes.

Quant a les columnes Sistema, Origen i Mensaje, les hem seleccionades per reflectir els components més rellevants dels registres de log. Utilitzar el tipus de dada VARCHAR per a aquestes columnes ens proporciona una estructura flexible i adaptable als tipus de dades que esperem emmagatzemar.

Finalment, hem triat utilitzar el tipus de dada TEXT per a la columna Mensaje per acomodar missatges de log de longitud variable. Això ens permet emmagatzemar missatges de log de qualsevol mida sense preocupar-nos per restriccions de longitud.*/


--1.2 Taula que rebrà les dades del fitxer

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



--1.3 Codi encarregat de carregar aquest fitxer

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

-- Opcional automatitzar amb cron (PAS 5 ) pero a la secció d'events en aquesta carpeta podem trobar el event corresponent 
--El script seria el següent 

#!/bin/bash

# Definir la ruta del fitxer syslog
file_path="/home/elon/syslog_$(date +'%Y-%m-%d')"

# Comanda per carregar el fitxer syslog a la base de dades
-- mysql -u elon -elon nom_practica -e "LOAD DATA INFILE '${file_path}' INTO TABLE CarregarLogs FIELDS TERMINATED BY ';' ENCLOSED BY '\"' LINES TERMINATED BY '\n';"

# en el crontab -e posarem la seguent linea al final del arziu
0 1 * * * /home/elon/scriptBD.sh




--PAS 2: TRACTAMENT I TAULES DE CONTROL

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

-- Afegir la columna addicional "es_cap_de_setmana"
ALTER TABLE CarregarLogs
ADD COLUMN es_cap_de_setmana BOOLEAN;

-- Actualitzar els valors de la columna "es_cap_de_setmana"
UPDATE CarregarLogs SET es_cap_de_setmana = 
CASE  
    WHEN DAYOFWEEK(Fecha) IN (1,7)
    THEN TRUE
    ELSE FALSE END;

--PAS 4  Creació de la taula Màster dels processos

--Creació taula màster dels processos

DROP TABLE IF EXISTS MasterTable;

CREATE TABLE IF NOT EXISTS MasterTable (
  Id INT NOT NULL AUTO_INCREMENT,
  NomProces VARCHAR(100),
  Descripcio VARCHAR(255),
  PRIMARY KEY(Id)
);

--Modificació de la taula de logs: 

-- Afegir una columna per fer referència a la taula màster dels processos
ALTER TABLE CarregarLogs
ADD COLUMN ProcessId INT,
ADD CONSTRAINT fk_process_id FOREIGN KEY (ProcessId) REFERENCES MasterProcess(Id);

-- Inserció de dades a la taula màster dels processos

-- Exemple d'inserció de dades a la taula màster dels processos
INSERT INTO MasterProcess (NomProcés, Descripció) VALUES
    ('Systemd[1]', 'systemd is a system and service manager'),
    ('rsyslogd', 'The rsyslog daemon is an enhanced syslogd');



--PAS 5:  Manteniment de la taula Màster dels processos

DELIMITER $$

CREATE PROCEDURE MantenimentTaulaMasterProcess()
BEGIN
    -- Afegir nous processos que no estiguin a la taula màster
    INSERT INTO MasterProcess (NomProcés, Descripció)
    SELECT DISTINCT LOWER(NomProcés), Descripció
    FROM CarregarLogs
    WHERE NomProcés NOT IN (SELECT NomProcés FROM MasterProcess);

    -- Validar que el NomProcés i la Descripció no siguin nuls
    UPDATE MasterProcess
    SET NomProcés = IFNULL(NomProcés, CONCAT('Valor_Null_', Id)),
        Descripció = IFNULL(Descripció, CONCAT('Valor_Null_', Id))
    WHERE NomProcés IS NULL OR Descripció IS NULL;

    -- Validar que el NomProcés sempre estigui en minúscules
    UPDATE MasterProcess
    SET NomProcés = LOWER(NomProcés)
    WHERE NomProcés <> LOWER(NomProcés);

    -- Mostrar missatges de correcció
    SELECT 'S\'han afegit nous processos a la taula màster.',
           'S\'han corregit els processos amb noms en majúscules.',
           'S\'han corregit les dades nules en la taula màster.';'
END $$

DELIMITER ;


-- PAS 9: Pas 8: Nous usuaris

CREATE USER 'usuari1'@'localhost' IDENTIFIED BY '71420';
GRANT SELECT ON DBPractica.* TO 'usuari1'@'localhost';

