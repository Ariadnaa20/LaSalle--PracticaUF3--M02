-- model relacional, tambe està el model relacional en png 

-- Creación de la tabla CarregarLogs
CREATE TABLE CarregarLogs (
    id INT AUTO_INCREMENT,
    Fecha DATE,
    Hora TIME,
    Sistema VARCHAR(50),
    Origen VARCHAR(50),
    Mensaje VARCHAR(255),
    ProcessId INT,
    es_cap_de_setmana BOOLEAN,
    PRIMARY KEY (id),
    FOREIGN KEY (ProcessId) REFERENCES MasterTable(Id)
);

-- Creación de la tabla RegistreFitxers
CREATE TABLE RegistreFitxers (
    id INT AUTO_INCREMENT,
    nom_fitxer VARCHAR(255),
    data_càrrega DATETIME,
    PRIMARY KEY (id)
);

-- Creación de la tabla NombreFilesInserides
CREATE TABLE NombreFilesInserides (
    id INT AUTO_INCREMENT,
    nom_fitxer VARCHAR(255),
    num_files_inserides INT,
    data_càrrega DATETIME,
    PRIMARY KEY (id)
);

-- Creación de la tabla MasterTable
CREATE TABLE MasterTable (
    Id INT AUTO_INCREMENT,
    NomProces VARCHAR(100),
    Descripcio VARCHAR(255),
    PRIMARY KEY (Id)
);

-- Creación de la tabla ControlCanvis
CREATE TABLE ControlCanvis (
    id INT AUTO_INCREMENT PRIMARY KEY,
    valor_vell TEXT,
    valor_nou TEXT,
    hora_canvi DATETIME,
    usuari_responsable VARCHAR(100),
    carregar_logs_id INT,
    FOREIGN KEY (carregar_logs_id) REFERENCES CarregarLogs(id)
);



-- Afegir FK'S a la taula de CarregarLogs

ALTER TABLE CarregarLogs ADD CONSTRAINT fk_registre_fitxers_nom_fitxer FOREIGN KEY (nom_fitxer) REFERENCES RegistreFitxers(nom_fitxer),
ADD CONSTRAINT fk_nombre_files_inserides_nom_fitxer FOREIGN KEY (nom_fitxer) REFERENCES NombreFilesInserides(nom_fitxer), 
ADD CONSTRAINT fk_master_table_process_id FOREIGN KEY (ProcessId) REFERENCES MasterTable(Id);



