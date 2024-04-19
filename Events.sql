-- Pol Hernàndez, Xavier Moreno, Ariadna Pascual

SET GLOBAL event_secheuduler= 1;

--Event PAS1_3  
DELIMITER $$

CREATE EVENT IF NOT EXISTS Replace_Script_Event
ON SCHEDULE
    EVERY 1 DAY STARTS '2024-04-08 23:59:59'
    COMMENT 'Reemplazar script con carga directa en evento'
DO
BEGIN
    DECLARE file_path VARCHAR(255);
    SET file_path = CONCAT('/home/elon/syslog_', DATE_FORMAT(NOW(), '%Y-%m-%d'));

    SET @load_query = CONCAT('LOAD DATA INFILE ', QUOTE(file_path), ' INTO TABLE CarregarLogs FIELDS TERMINATED BY \';\' ENCLOSED BY \'""\' LINES TERMINATED BY \'\\n\';');
    PREPARE stmt FROM @load_query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END$$

DELIMITER ;


--Event PAS 7, per executar el backup cada diumenge 

DELIMITER $$

CREATE EVENT IF NOT EXISTS Backup_Event
ON SCHEDULE
    EVERY 1 WEEK STARTS CURRENT_TIMESTAMP
    COMMENT 'Backup de la base de datos cada domingo'
DO
BEGIN
    DECLARE current_date DATE;
    SET current_date = CURDATE();
    
    IF current_date <= '2024-07-01' THEN
        CALL RealitzarBackup();
    END IF;
END$$

DELIMITER ;




