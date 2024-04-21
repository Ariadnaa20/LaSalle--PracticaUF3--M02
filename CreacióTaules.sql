--Pol Hernàndez, Xavier Moreno, Ariadna Pascual

--PAS 1: CÀRREGA DE FITXERS

--1.1 Plantejament de l'estructura de la taula

/* 
Seguint el fitxer proporcionat que es idèntic al nostre de la maquina elon (captura al pdf proporcionat), hem decidit estructurar la taula d'aquesta manera per diverses raons. En primer lloc, hem optat per utilitzar una clau primària autoincremental per a la columna id per proporcionar una identificació única per a cada registre de log. Això facilita la gestió de les dades i les operacions de consulta.

En segon lloc, hem separar la data i l'hora en columnes independents (Fecha i Hora) perquè ens permet gestionar de manera més flexible les dades i facilita les consultes que necessiten filtrar per data, hora o intervals de temps específics tal com vem fer a Sistemes.

Quant a les columnes Sistema, Origen i Mensaje, les hem seleccionades per reflectir els components més rellevants dels registres de log. Utilitzar el tipus de dada VARCHAR per a aquestes columnes ens proporciona una estructura flexible i adaptable als tipus de dades que esperem emmagatzemar.

Finalment, hem triat utilitzar el tipus de dada TEXT per a la columna Mensaje per acomodar missatges de log de longitud variable. Això ens permet emmagatzemar missatges de log de qualsevol mida sense preocupar-nos per restriccions de longitud.*/


--1.2 Taula que rebrà les dades del fitxer

USE DBPractica;  -- la nostra base de dades 

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

--La taula al final de la practia tindrà aquest format 
CREATE TABLE CarregarLogs (
    id INT AUTO_INCREMENT,
    Fecha DATE,
    Hora TIME,
    Sistema VARCHAR(50),
    Origen VARCHAR(50),
    Mensaje VARCHAR(255),
    ProcessId INT,
    es_cap_de_setmana BOOLEAN,
    nom_fitxer VARCHAR(255),  
    PRIMARY KEY (id),
    FOREIGN KEY (ProcessId) REFERENCES MasterTable(Id),
    FOREIGN KEY (nom_fitxer) REFERENCES RegistreFitxers(nom_fitxer),
    FOREIGN KEY (nom_fitxer) REFERENCES NombreFilesInserides(nom_fitxer)
);



--1.3 Codi encarregat de carregar aquest fitxer

--Nosaltres hem decidit modificar el proces de carrga de dades peer incloure el nom del archiu 
DELIMITER $$

CREATE PROCEDURE CarregarDades(IN nom_fitxer_actual VARCHAR(255))
BEGIN
    
    LOAD DATA INFILE nom_fitxer_actual
    INTO TABLE CarregarLogs
    FIELDS TERMINATED BY ',' ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    (Fecha, Hora, Sistema, Origen, Mensaje)
    SET nom_fitxer = nom_fitxer_actual;  
END$$

DELIMITER ;

DELIMITER $$


--Seguidament crear el event cada dia 
CREATE EVENT IF NOT EXISTS ImportarDades
ON SCHEDULE EVERY 1 DAY 
STARTS '2024-04-08 23:59:59'
DO
    BEGIN
        SET @ruta_arxiu = CONCAT('/home/elon/syslog_', DATE_FORMAT(NOW(), '%Y-%m-%d'));
        CALL CarregarDades(@ruta_arxiu);
    END $$

DELIMITER ;


-- Opcional automatitzar amb cron (PAS 5 ) pero a la secció d'events en aquesta carpeta podem trobar el event corresponent 
--El script corresponent seria el següent tambè està en el fitxer anomenat Script.sh

#!/bin/bash

# Definir la ruta del fitxer syslog
file_path="/home/elon/syslog_$(date +'%Y-%m-%d')"

# Amb això carreguem el fitxer syslog a la base de dades
-- mysql -u elon -elon nom_practica -e "LOAD DATA INFILE '${file_path}' INTO TABLE CarregarLogs FIELDS TERMINATED BY ';' ENCLOSED BY '\"' LINES TERMINATED BY '\n';"

# en el crontab -e posarem la seguent linea al final del arziu
0 1 * * * /home/elon/scriptBD.sh




--PAS 2: TRACTAMENT I TAULES DE CONTROL

-- 2.1 Creació de taules de control 


CREATE TABLE RegistreFitxers (
    id INT AUTO_INCREMENT,
    nom_fitxer VARCHAR(255),
    data_carrega DATETIME,
    PRIMARY KEY (nom_fitxer)  --Definint nom_fitxer com la clau primaria
);

-- Creación de la tabla NombreFilesInserides
CREATE TABLE NombreFilesInserides (
    id INT AUTO_INCREMENT,
    nom_fitxer VARCHAR(255),
    num_files_inserides INT,
    data_carrega DATETIME,
    PRIMARY KEY (nom_fitxer)  
);


-- 2.2 Procés de tractament dels fitxers syslog 

-- Obtenció del fitxer del dia anterior

SET @dia_semana = DAYOFWEEK(NOW()) - 2; -- Restem 2 per a   que el dilluns sigui 0, dimarts 1, etc.
-- DAYOFWEEK el q fa  retorna valors de 1 a 7, on el diumenge és 1 i el dissabte és 7. Per tant, si volem obtenir el dia anterior, hem de fer que el dilluns sigui 0, el dimarts 1 i així successivamet, per poder restar el nombre de dies adequat i obenir el dia anterior.
SET @fitxer_dia_anterior = CONCAT('/home/elon/syslog_', DATE_FORMAT(NOW() - INTERVAL @dia_semana DAY, '%Y-%m-%d'));

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
    WHEN DAYOFWEEK(Fecha) IN (1,7)  -- el 1 es  diumenge i el 7 és dissabte 
    THEN TRUE --true si es cap de setmana 
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
ADD CONSTRAINT fk_process_id FOREIGN KEY (ProcessId) REFERENCES MasterTable(Id);





--PAS 5:  Manteniment de la taula Màster dels processos

DELIMITER $$

CREATE PROCEDURE MantenimentTaulaMasterProcess()
BEGIN
    DECLARE error_message VARCHAR(255);

    -- Afegir nous processos que no estiguin a la taula màster
    INSERT INTO MasterTable (NomProces, Descripcio)
    SELECT DISTINCT LOWER(NomProces), Descripcio
    FROM CarregarLogs
    WHERE NomProcés NOT IN (SELECT NomProces FROM MasterTable);

    -- Validar que el NomProces i la Descripcio no siguin nuls
    UPDATE MasterTable
    SET NomProces = IFNULL(NomProces, CONCAT('Valor_Null_', Id)),
        Descripcio = IFNULL(Descripcio, CONCAT('Valor_Null_', Id))
    WHERE NomProces IS NULL OR Descripcio IS NULL;

    -- Validar que el NomProces sempre estigui en minúscules
    UPDATE MasterTable
    SET NomProces = LOWER(NomProces)
    WHERE NomProces <> LOWER(NomProces);

    -- Comprovar si hi ha hagut canvis i mostrar missatges d'error
    SELECT 'S\'han afegit nous processos a la taula màster.' INTO error_message
    WHERE ROW_COUNT() > 0;
    IF ROW_COUNT() = 0 THEN
        SELECT 'No s\'han afegit nous processos a la taula màster.' INTO error_message;
    END IF;
    
    SELECT 'S\'han corregit els processos amb noms en majúscules.' INTO error_message
    WHERE ROW_COUNT() > 0;
    IF ROW_COUNT() = 0 THEN
        SELECT 'No s\'han corregit els processos amb noms en majúscules.' INTO error_message;
    END IF;

    SELECT 'S\'han corregit les dades nules en la taula màster.' INTO error_message
    WHERE ROW_COUNT() > 0;
    IF ROW_COUNT() = 0 THEN
        SELECT 'No s\'han corregit les dades nules en la taula màster.' INTO error_message;
    END IF;

    SELECT error_message;
END $$

DELIMITER ;


--explicació del procediment:
/*
El procediment que hem creat s'encarrega de mantenir la coherència de la taula MasterTable que emmagatzema informació sobre els processos dels quals tenim logs. Primer, comprovem si hi ha nous processos a partir dels logs carregats a la taula CarregarLogs. Si trobem nous processos, els afegim a la taula MasterTable.

Seguidament, validem les dades existents a la taula MasterTable. Verifiquem que cap dels camps NomProces i Descripcio estiguen buits. Si trobem camps buits, els substituïm per una cadena que indica que el valor era nul. També ens assegurem que els noms dels processos sempre estiguen en minúscules. Si trobem processos amb noms en majúscules, els convertim a minúscules.

Després de realitzar aquestes comprovacions i correccions, revisem si s'han produït canvis i, en cas afirmatiu, mostrem els missatges corresponents indicant quines operacions s'han realitzat amb èxit. Si no s'han produït canvis, mostrem missatges indicant que no s'ha realitzat cap acció.

*/




