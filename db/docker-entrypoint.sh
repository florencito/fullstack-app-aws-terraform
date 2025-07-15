#!/bin/bash

echo "🛠️ Configurando la base de datos RDS..."

mysql -h "${DB_HOST}" \
      -P 3306 \
      -u "${DB_USER}" \
      -p"${DB_PASSWORD}" < db/init.sql

echo "✅ Script SQL ejecutado correctamente."
