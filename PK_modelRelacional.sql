--Pol Hernàndez, Xavier Moreno, Ariadna Pascual 

-- model relacional, tambe està el model relacional en png 


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



CREATE TABLE RegistreFitxers (
    id INT AUTO_INCREMENT,
    nom_fitxer VARCHAR(255),
    data_carrega DATETIME,
    PRIMARY KEY (nom_fitxer)  -- Definiendo nom_fitxer como la clave primaria
);

-- Creación de la tabla NombreFilesInserides
CREATE TABLE NombreFilesInserides (
    id INT AUTO_INCREMENT,
    nom_fitxer VARCHAR(255),
    num_files_inserides INT,
    data_carrega DATETIME,
    PRIMARY KEY (nom_fitxer)  -- Definiendo nom_fitxer como la clave primaria
);

CREATE TABLE MasterTable (
    Id INT AUTO_INCREMENT,
    NomProces VARCHAR(100),
    Descripcio VARCHAR(255),
    PRIMARY KEY (Id)
);


CREATE TABLE ControlCanvis (
    id INT AUTO_INCREMENT PRIMARY KEY,
    valor_vell TEXT,
    valor_nou TEXT,
    hora_canvi DATETIME,
    usuari_responsable VARCHAR(100),
    carregar_logs_id INT,
    FOREIGN KEY (carregar_logs_id) REFERENCES CarregarLogs(id)
);





