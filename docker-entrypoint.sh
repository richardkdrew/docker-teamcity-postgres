#!/bin/bash

set -e

if [ "$2" = 'run' ]; then

  # we need to add the database.properties file here, after docker has mounted the external volume
  echo "Setting up environment..."
  echo "TeamCity DATA path is set to" ${TEAMCITY_DATA_PATH}
  echo "TeamCity HOME path is set to" ${TEAMCITY_HOME}
  echo

  : ${TEAMCITY_DB_SERVER:=teamcity-db}
  : ${TEAMCITY_DB:=teamcity}
  : ${TEAMCITY_DB_USER:=teamcity}
  : ${TEAMCITY_DB_PASSWORD:=P@55w0rd}

  export TEAMCITY_DB_SERVER
  export TEAMCITY_DB
  export TEAMCITY_DB_USER
  export TEAMCITY_DB_PASSWORD

  echo "TeamCity Database Server is set to" ${TEAMCITY_DB_SERVER}
  echo "TeamCity Database Name is set to" ${TEAMCITY_DB}
  echo "TeamCity Database User is set to" ${TEAMCITY_DB_USER}
  echo "TeamCity Database Password is set to" ${TEAMCITY_DB_PASSWORD}
  echo

  echo "Setting up database configuration..."
  mkdir -p ${TEAMCITY_DATA_PATH}/config
  touch ${TEAMCITY_DATA_PATH}/config/database.properties
  echo "connectionUrl=jdbc:postgresql://"${TEAMCITY_DB_SERVER}"/"${TEAMCITY_DB} >> ${TEAMCITY_DATA_PATH}/config/database.properties
  echo "connectionProperties.user="${TEAMCITY_DB_USER} >> ${TEAMCITY_DATA_PATH}/config/database.properties
  echo "connectionProperties.password="${TEAMCITY_DB_PASSWORD} >> ${TEAMCITY_DATA_PATH}/config/database.properties
  echo "maxConnections=50" >> ${TEAMCITY_DATA_PATH}/config/database.properties
  echo "testOnBorrow=false" >> ${TEAMCITY_DATA_PATH}/config/database.properties

  if [ ! -f ${TEAMCITY_DATA_PATH}"/lib/jdbc/postgresql-9.3-1103.jdbc41.jar" ]; then
    echo "Downloading postgres JDBC driver..."
    mkdir -p ${TEAMCITY_DATA_PATH}/lib/jdbc
    curl -SL http://jdbc.postgresql.org/download/postgresql-9.3-1103.jdbc41.jar > ${TEAMCITY_DATA_PATH}/lib/jdbc/postgresql-9.3-1103.jdbc41.jar
  fi

  # we need to set the permissions here because docker mounts volumes as root
  echo "Setting up permissions..."
  chown -R teamcity:teamcity \
    ${TEAMCITY_DATA_PATH} \
    ${TEAMCITY_HOME}

  echo "Starting TeamCity..."
  HOME=${TEAMCITY_HOME}/bin/ exec gosu teamcity "$@"
fi

exec "$@"
