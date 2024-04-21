-- Pol Hernàndez, Xavier Moreno, Ariadna Pascual

SET GLOBAL event_secheuduler= 1;

--Event PAS1_3  
DELIMITER $$

DELIMITER &&

DROP EVENT IF EXISTS ImportarDades &&

CREATE EVENT IF NOT EXISTS ImportarDades
ON SCHEDULE EVERY 1 DAY 
STARTS '2024-04-08 23:59:59'
DO
    BEGIN
        SET @ruta_arxiu = CONCAT('/home/elon/syslog_', DATE_FORMAT(NOW(), '%Y-%m-%d'));
        SET @consulta = CONCAT('LOAD DATA INFILE "', @ruta_arxiu, '" INTO TABLE CarregarLogs FIELDS TERMINATED BY ";" ENCLOSED BY \'""\' LINES TERMINATED BY "\n";');
        PREPARE stmt FROM @consulta;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END &&

DELIMITER ;



--Event PAS 7, per executar el backup cada diumenge 

DELIMITER $$

CREATE EVENT IF NOT EXISTS Backup_Event
ON SCHEDULE
    EVERY 1 WEEK STARTS CURRENT_DATE + INTERVAL (7 - DAYOFWEEK(CURRENT_DATE)) DAY
    COMMENT 'Backup de la bbdd cada diumnege'
DO
BEGIN
    DECLARE current_date DATE;
    SET current_date = CURDATE();
    
    IF current_date < '2024-07-01' THEN
        CALL RealitzarCopiaSeguretat();
    ELSE
        DROP EVENT IF EXISTS Backup_Event;
    END IF;
END$$

DELIMITER ;






