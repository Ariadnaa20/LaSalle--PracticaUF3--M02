-- Pol Hernàndez, Xavier Moreno, Ariadna Pascual 

--PAS 3: EXTRACCIÓ 

DELIMITER $$

DROP PROCEDURE IF EXISTS ExportarDadesControl $$
CREATE PROCEDURE ExportarDadesControl()
BEGIN
    -- Exportació del registre dels fitxers carregats
    SELECT * INTO OUTFILE '/home/elon/registre_fitxers.csv'
    FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    FROM RegistreFitxers;

    -- Exportació del nombre de files inserides per cada fitxer
    SELECT * INTO OUTFILE '/home/elon/nombre_files_inserides.csv'
    FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    FROM NombreFilesInserides;
END $$

DELIMITER ;


CALL ExportarDadesControl(); -- no te paràmetres


--PAS 5: Manteniment de la taula Màster dels processos



-- PAS 7 : BACK UP DE LA BBDD 
DELIMITER $$

CREATE PROCEDURE RealitzarCopiaSeguretat()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE tableName VARCHAR(255);
    DECLARE currentDate VARCHAR(10);
    DECLARE cur1 CURSOR FOR SELECT table_name FROM information_schema.tables WHERE table_schema = 'DBPractica' AND table_type = 'BASE TABLE';
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    SET currentDate = DATE_FORMAT(NOW(), '%Y%m%d');

    OPEN cur;

    read_loop: LOOP
        FETCH cur1 INTO tableName;
        IF done THEN
            LEAVE read_loop;
        END IF;

        SET @backupTableName = CONCAT('backup_', tableName, '_', currentDate);
        SET @sql = CONCAT('CREATE TABLE ', @backupTableName, ' LIKE DBPractica.', tableName);
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SET @sql = CONCAT('INSERT INTO ', @backupTableName, ' SELECT * FROM DBPractica.', tableName);
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END LOOP;

    CLOSE cur1;
END $$

DELIMITER ;

