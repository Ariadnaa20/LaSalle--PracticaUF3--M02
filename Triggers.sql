-- Pol Hernàndez, Xavier Moreno, Ariadna Pascual

--PAS 6: Triggers de control


--Trigger d'inserció
--Aquest trigger s'executarà automàticament després de cada inserció a la taula Màster. Enregistrará un registre a la taula de control amb el nou valor (NomProcés) i l'usuari responsable de la inserció.
CREATE TRIGGER insert_trigger
AFTER INSERT ON CarregarLogs
FOR EACH ROW
BEGIN
    INSERT INTO RegistreFitxers (nom_fitxer, data_carrega) VALUES (NEW.nom_fitxer, NOW());
    INSERT INTO NombreFilesInserides (nom_fitxer, num_files_inserides, data_carrega) VALUES (NEW.nom_fitxer, 1, NOW());
END;


--Taula cintrol
CREATE TABLE IF NOT EXISTS ControlCanvis (
    id INT AUTO_INCREMENT PRIMARY KEY,
    valor_vell TEXT,
    valor_nou TEXT,
    hora_canvi DATETIME,
    usuari_responsable VARCHAR(255)
);


--6.2 Crea un procés que faci un tracking de la taula Màster i registri les modificacions i els borrats de registres

DELIMITER $$

CREATE TRIGGER master_table_update_trigger
AFTER UPDATE ON MasterTable
FOR EACH ROW
BEGIN
    INSERT INTO ControlCanvis (valor_vell, valor_nou, hora_canvi, usuari_responsable)
    VALUES (OLD.NomProces, NEW.NomProces, NOW(), USER());
END $$


CREATE TRIGGER master_table_delete_trigger
AFTER DELETE ON MasterTable
FOR EACH ROW
BEGIN
    INSERT INTO ControlCanvis (valor_vell, valor_nou, hora_canvi, usuari_responsable)
    VALUES (OLD.NomProces, NULL, NOW(), USER());
END $$

DELIMITER ;

































--Trigger de modificació 
--Aquest trigger s'executarà després de cada actualització a la taula Màster. Enregistrará un registre a la taula de control amb el valor anterior (NomProcés) i el nou valor (NomProcés), juntament amb l'usuari responsable de l'acció.
CREATE TRIGGER UpdateControlCanvis
AFTER UPDATE ON MasterProcess
FOR EACH ROW
BEGIN
    INSERT INTO ControlCanvis (valor_vell, valor_nou, hora_canvi, usuari_responsable)
    VALUES (OLD.NomProcés, CONCAT('Nou valor: ', NEW.NomProcés), NOW(), CURRENT_USER());
END;

--Trigger de borrat 
-- Aquest trigger s'executarà després de cada esborrat a la taula Màster. Enregistrará un registre a la taula de control amb el valor anterior (NomProcés) i el missatge 'Valor eliminat', juntament amb l'usuari responsable de l'acció.
CREATE TRIGGER DeleteControlCanvis
AFTER DELETE ON MasterProcess
FOR EACH ROW
BEGIN
    INSERT INTO ControlCanvis (valor_vell, valor_nou, hora_canvi, usuari_responsable)
    VALUES (OLD.NomProcés, 'Valor eliminat', NOW(), CURRENT_USER());
END;



