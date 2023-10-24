#!/bin/bash

set -e

echo "[SQLSERVER]
Driver = ODBC Driver 17 for SQL Server
Server = tcp:${SQLCMDSERVER},1433
Encrypt = yes
TrustServerCertificate = no
Connection Timeout = 30" | sudo tee /etc/odbc.ini >/dev/null

# if SQLADMINPASSWORD is empty, the script will try to use MSI
if [[ -z "${SQLADMINPASSWORD}" ]]; then
  echo "Authentication = ActiveDirectoryMsi" | sudo tee -a /etc/odbc.ini >/dev/null
fi

if [[ -z "${SQLADMINPASSWORD}" ]]; then
  sqlcmd -v DBUSERNAMES="${DBUSERNAMES}" DBROLES="${DBROLES}" -S SQLSERVER -d "${SQLCMDDBNAME}" -i "${SQLFILEPATH}" -D
else
  # if using user/password, we must pass it to the command (user/password in odbc.ini on Linux is not supported)
  sqlcmd -v DBUSERNAMES="${DBUSERNAMES}" DBROLES="${DBROLES}" -S SQLSERVER -d "${SQLCMDDBNAME}" -i "${SQLFILEPATH}" -D -U sqladmin -P "${SQLADMINPASSWORD}"
fi
