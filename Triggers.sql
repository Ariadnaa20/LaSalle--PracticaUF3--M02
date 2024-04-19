-- Pol Hernàndez, Xavier Moreno, Ariadna Pascual

--PAS 6 Triggers de control

--Creació taula de control
CREATE TABLE IF NOT EXISTS ControlCanvis (
    id INT AUTO_INCREMENT PRIMARY KEY,
    valor_vell TEXT,
    valor_nou TEXT,
    hora_canvi DATETIME,
    usuari_responsable VARCHAR(100)
);

--Trigger d'inserció
--Aquest trigger s'executarà automàticament després de cada inserció a la taula Màster. Enregistrará un registre a la taula de control amb el nou valor (NomProcés) i l'usuari responsable de la inserció.
CREATE TRIGGER InsertControlCanvis
AFTER INSERT ON MasterProcess
FOR EACH ROW
BEGIN
    INSERT INTO ControlCanvis (valor_vell, valor_nou, hora_canvi, usuari_responsable)
    VALUES ('', CONCAT('Nou registre: ', NEW.NomProcés), NOW(), CURRENT_USER());
END;


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



