#!/bin/bash

set -e

echo "[SQLSERVER]
Driver = ODBC Driver 17 for SQL Server
Server = tcp:${SQLCMDSERVER},1433
Encrypt = yes
TrustServerCertificate = no
Connection Timeout = 30" | sudo tee /etc/odbc.ini >/dev/null

# if USEACCESSTOKEN is empty, the script will try to use MSI
if [[ -z "${USEACCESSTOKEN}" ]]; then
  echo "Authentication = ActiveDirectoryMsi" | sudo tee -a /etc/odbc.ini >/dev/null
fi

if [[ -z "${USEACCESSTOKEN}" ]]; then
  sqlcmd -v DBUSERNAMES="${DBUSERNAMES}" DBROLES="${DBROLES}" -S SQLSERVER -d "${SQLCMDDBNAME}" -i "${SQLFILEPATH}" -D
else
  # the SqlServer Powershell module allows to use an access_token from the current connected user to be used to query the SqlServer instance
  # the user must be an admin
  access_token=$(az account get-access-token --resource https://database.windows.net | jq -r .accessToken)
  pwsh -c "Install-Module -Name SqlServer -Confirm; Install-Module Az.Accounts -Confirm; Import-Module SqlServer; Import-Module Az.Accounts; Invoke-Sqlcmd -ServerInstance '${SQLCMDSERVER}' -AccessToken '${access_token}' -InputFile '${SQLFILEPATH}';"
fi
