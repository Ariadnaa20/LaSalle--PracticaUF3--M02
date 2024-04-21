#Pol Hernàndez, Xavier Moreno, Ariadna Pascual

#!/bin/bash

# Definim la ruta del fitxer syslog
file_path="/home/elon/syslog_$(date +'%Y-%m-%d')"

# Mostrem un missatge per indicar que la càrrega està en curs
echo "Iniciant càrrega de dades des de l'arxiu: $file_path"

# Connectem a la base de dades i executem la càrrega de dades
mysql -u elon elon -e "USE DBPractica; LOAD DATA INFILE '$file_path' INTO TABLE CarregarLogs FIELDS TERMINATED BY ';' ENCLOSED BY '\"' LINES TERMINATED BY '\n';"

# Mostrem un missatge indicant que la càrrega ha finalitzat
echo "La càrrega de dades ha finalitzat"


¡
#La sentència al cron seria aixi 
0 1 * * * /home/elon/scriptBD.sh


#pero se li han de donar permissos 
elon@elon:~: chmod +x /home/elon/scriptBD.sh


