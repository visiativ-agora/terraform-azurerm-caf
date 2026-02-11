#!/bin/bash

set -e

# Obtenir le token Entra ID pour PostgreSQL avec la ressource correcte
export PGPASSWORD=$(az account get-access-token --resource https://ossrdbms-aad.database.windows.net --query accessToken --output tsv)

# Vérifier que le token est obtenu
if [ -z "$PGPASSWORD" ]; then
    echo "ERROR: Failed to obtain Entra ID token"
    exit 1
fi

echo "Creating Entra ID principals and setting permissions..."

# Convertir les variables d'environnement en arrays
IFS=',' read -ra USERNAMES <<< "$DBUSERNAMES"
IFS=',' read -ra OBJECTIDS <<< "$DBOBJECTIDS"
IFS=',' read -ra ROLES <<< "$DBROLES"
IFS='|||' read -ra CUSTOMGRANTS <<< "$CUSTOMGRANTS"

# Étape 1: Créer les principals sur la base postgres
echo "Step 1: Creating Entra ID principals on postgres database..."
for i in "${!USERNAMES[@]}"; do
    USERNAME="${USERNAMES[$i]}"
    OBJECTID="${OBJECTIDS[$i]}"
    
    echo "Creating principal: $USERNAME (Object ID: $OBJECTID)"
    
    # Déterminer le type de principal (service pour MSI, group pour groupes AD)
    PRINCIPAL_TYPE="service"
    if [[ "$USERNAME" == *"@"* ]]; then
        PRINCIPAL_TYPE="user"
    fi
    
    PGDATABASE="postgres" psql -h "$PGHOST" -p "$PGPORT" -U "$PGADMINUSER" -c \
        "SELECT * FROM pgaadauth_create_principal_with_oid('$USERNAME', '$OBJECTID', '$PRINCIPAL_TYPE', false, false);" \
        || echo "Principal $USERNAME may already exist, continuing..."
done

# Étape 2: Assigner les permissions sur la base de données applicative
echo "Step 2: Setting permissions on database $PGDATABASE..."

# Créer un fichier SQL temporaire avec toutes les commandes
TEMP_SQL=$(mktemp)

for i in "${!USERNAMES[@]}"; do
    USERNAME="${USERNAMES[$i]}"
    ROLE="${ROLES[$i]}"
    CUSTOMGRANT="${CUSTOMGRANTS[$i]}"
    
    echo "-- Permissions for $USERNAME (role: $ROLE)" >> "$TEMP_SQL"
    
    # GRANT CONNECT
    echo "GRANT CONNECT ON DATABASE \"$PGDATABASE\" TO \"$USERNAME\";" >> "$TEMP_SQL"
    
    # GRANT USAGE on schema public
    echo "GRANT USAGE ON SCHEMA public TO \"$USERNAME\";" >> "$TEMP_SQL"
    
    # Permissions selon le role_type
    case "$ROLE" in
        readonly)
            echo "GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"$USERNAME\";" >> "$TEMP_SQL"
            echo "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO \"$USERNAME\";" >> "$TEMP_SQL"
            ;;
        readwrite)
            echo "GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO \"$USERNAME\";" >> "$TEMP_SQL"
            echo "GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO \"$USERNAME\";" >> "$TEMP_SQL"
            echo "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO \"$USERNAME\";" >> "$TEMP_SQL"
            echo "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE, SELECT ON SEQUENCES TO \"$USERNAME\";" >> "$TEMP_SQL"
            ;;
        owner)
            echo "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO \"$USERNAME\";" >> "$TEMP_SQL"
            echo "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO \"$USERNAME\";" >> "$TEMP_SQL"
            echo "GRANT ALL PRIVILEGES ON SCHEMA public TO \"$USERNAME\";" >> "$TEMP_SQL"
            echo "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO \"$USERNAME\";" >> "$TEMP_SQL"
            echo "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO \"$USERNAME\";" >> "$TEMP_SQL"
            ;;
    esac
    
    # Custom grants si spécifiés
    if [ -n "$CUSTOMGRANT" ]; then
        echo "-- Custom grants for $USERNAME" >> "$TEMP_SQL"
        echo "$CUSTOMGRANT" >> "$TEMP_SQL"
    fi
    
    echo "" >> "$TEMP_SQL"
done

# Exécuter toutes les commandes SQL
psql -h "$PGHOST" -p "$PGPORT" -U "$PGADMINUSER" -f "$TEMP_SQL"

# Nettoyer
rm -f "$TEMP_SQL"

echo "Permissions set successfully for all users on database $PGDATABASE"
