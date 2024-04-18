-- Pol hernàndez, Xavier Moreno, Ariadna Pascual 

--PAS 3: EXTRACCIÓ 

DELIMITER //

CREATE PROCEDURE ExportarDadesControl()
BEGIN
    -- Exportació del registre dels fitxers carregats
    SELECT * INTO OUTFILE '/ruta/registre_fitxers.csv'
    FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    FROM RegistreFitxers;

    -- Exportació del nombre de files inserides per cada fitxer
    SELECT * INTO OUTFILE '/ruta/nombre_files_inserides.csv'
    FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    FROM NombreFilesInserides;
END //

DELIMITER ;


CALL ExportarDadesControl();


-- PAS 7 : BACK UP DE LA BBDD 
DELIMITER $$

CREATE PROCEDURE RealitzarBackup()
BEGIN
    DECLARE nom_taula VARCHAR(255);
    DECLARE data_actual VARCHAR(10);
    DECLARE done INT DEFAULT FALSE;
    DECLARE backup_cursor CURSOR FOR SELECT table_name FROM information_schema.tables WHERE table_schema = 'DBPractica'; -- Nom de la nostra bbdd
    
    -- Obtenir la data actual en el format YYYYMMDD
    SET data_actual = DATE_FORMAT(NOW(), '%Y%m%d');
    
    -- Obrir el cursor
    OPEN backup_cursor;

    -- Recórrer les taules i fer còpies de seguretat
    backup_loop: LOOP
        FETCH backup_cursor INTO nom_taula;
        IF done THEN
            LEAVE backup_loop;
        END IF;

        SET @query = CONCAT('CREATE TABLE IF NOT EXISTS ', nom_taula, '_', data_actual, ' LIKE ', nom_taula);
        PREPARE stmt FROM @query;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SET @query = CONCAT('INSERT INTO ', nom_taula, '_', data_actual, ' SELECT * FROM ', nom_taula);
        PREPARE stmt FROM @query;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

    END LOOP;

    -- Tancar el cursor
    CLOSE backup_cursor;
END$$

DELIMITER ;
