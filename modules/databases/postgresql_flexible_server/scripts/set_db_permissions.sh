# #!/bin/bash

# set -e

# # Obtenir le token Entra ID pour PostgreSQL avec la ressource correcte
# export PGPASSWORD=$(az account get-access-token --resource https://ossrdbms-aad.database.windows.net --query accessToken --output tsv)

# # Vérifier que le token est obtenu
# if [ -z "$PGPASSWORD" ]; then
#     echo "ERROR: Failed to obtain Entra ID token"
#     exit 1
# fi

# echo "Creating Entra ID principals and setting permissions..."

# # Convertir les variables d'environnement en arrays
# IFS=',' read -ra USERNAMES <<< "$DBUSERNAMES"
# IFS=',' read -ra OBJECTIDS <<< "$DBOBJECTIDS"
# IFS=',' read -ra ROLES <<< "$DBROLES"
# IFS='|||' read -ra CUSTOMGRANTS <<< "$CUSTOMGRANTS"

# # Étape 1: Créer les principals sur la base postgres
# echo "Step 1: Creating Entra ID principals on postgres database..."
# for i in "${!USERNAMES[@]}"; do
#     USERNAME="${USERNAMES[$i]}"
#     OBJECTID="${OBJECTIDS[$i]}"
    
#     echo "Creating principal: $USERNAME (Object ID: $OBJECTID)"
    
#     # Déterminer le type de principal (service pour MSI, group pour groupes AD)
#     PRINCIPAL_TYPE="service"
#     if [[ "$USERNAME" == *"@"* ]]; then
#         PRINCIPAL_TYPE="user"
#     fi
    
#     PGDATABASE="postgres" psql -h "$PGHOST" -p "$PGPORT" -U "$PGADMINUSER" -c \
#         "SELECT * FROM pgaadauth_create_principal_with_oid('$USERNAME', '$OBJECTID', '$PRINCIPAL_TYPE', false, false);" \
#         || echo "Principal $USERNAME may already exist, continuing..."
# done

# # Étape 2: Assigner les permissions sur la base de données applicative
# echo "Step 2: Setting permissions on database $PGDATABASE..."

# # Créer un fichier SQL temporaire avec toutes les commandes
# TEMP_SQL=$(mktemp)

# for i in "${!USERNAMES[@]}"; do
#     USERNAME="${USERNAMES[$i]}"
#     ROLE="${ROLES[$i]}"
#     CUSTOMGRANT="${CUSTOMGRANTS[$i]}"
    
#     echo "-- Permissions for $USERNAME (role: $ROLE)" >> "$TEMP_SQL"
    
#     # GRANT CONNECT
#     echo "GRANT CONNECT ON DATABASE \"$PGDATABASE\" TO \"$USERNAME\";" >> "$TEMP_SQL"
    
#     # GRANT USAGE on schema public
#     echo "GRANT USAGE ON SCHEMA public TO \"$USERNAME\";" >> "$TEMP_SQL"
    
#     # Permissions selon le role_type
#     case "$ROLE" in
#         readonly)
#             echo "GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"$USERNAME\";" >> "$TEMP_SQL"
#             echo "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO \"$USERNAME\";" >> "$TEMP_SQL"
#             ;;
#         readwrite)
#             echo "GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO \"$USERNAME\";" >> "$TEMP_SQL"
#             echo "GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO \"$USERNAME\";" >> "$TEMP_SQL"
#             echo "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO \"$USERNAME\";" >> "$TEMP_SQL"
#             echo "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE, SELECT ON SEQUENCES TO \"$USERNAME\";" >> "$TEMP_SQL"
#             ;;
#         owner)
#             echo "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO \"$USERNAME\";" >> "$TEMP_SQL"
#             echo "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO \"$USERNAME\";" >> "$TEMP_SQL"
#             echo "GRANT ALL PRIVILEGES ON SCHEMA public TO \"$USERNAME\";" >> "$TEMP_SQL"
#             echo "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO \"$USERNAME\";" >> "$TEMP_SQL"
#             echo "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO \"$USERNAME\";" >> "$TEMP_SQL"
#             ;;
#     esac
    
#     # Custom grants si spécifiés
#     if [ -n "$CUSTOMGRANT" ]; then
#         echo "-- Custom grants for $USERNAME" >> "$TEMP_SQL"
#         echo "$CUSTOMGRANT" >> "$TEMP_SQL"
#     fi
    
#     echo "" >> "$TEMP_SQL"
# done

# # Exécuter toutes les commandes SQL
# psql -h "$PGHOST" -p "$PGPORT" -U "$PGADMINUSER" -f "$TEMP_SQL"

# # Nettoyer
# rm -f "$TEMP_SQL"

# echo "Permissions set successfully for all users on database $PGDATABASE"


#!/bin/bash

set -e

echo "Authenticating with Azure AD administrator: $PGADMINUSER (Type: $PGADMINTYPE)"

# Fonction pour obtenir le token selon le type d'administrateur
get_admin_token() {
    local admin_type="$1"
    local admin_object_id="$2"
    
    case "$admin_type" in
        "ServicePrincipal")
            # Pour une Managed Identity ou Service Principal
            echo "Getting token for Service Principal/Managed Identity..." >&2
            
            # Vérifier si on est dans un contexte avec une MSI (Azure VM, Container Instance, etc.)
            if [ -n "$MSI_ENDPOINT" ] && [ -n "$MSI_SECRET" ]; then
                # Contexte MSI (Azure Pipeline, Container Instance, etc.)
                curl -s "$MSI_ENDPOINT?resource=https://ossrdbms-aad.database.windows.net&api-version=2019-08-01" \
                     -H "Secret: $MSI_SECRET" | jq -r .access_token
            elif [ -n "$IDENTITY_ENDPOINT" ] && [ -n "$IDENTITY_HEADER" ]; then
                # Contexte MSI pour App Service / Functions
                curl -s "$IDENTITY_ENDPOINT?resource=https://ossrdbms-aad.database.windows.net&api-version=2019-08-01" \
                     -H "X-IDENTITY-HEADER: $IDENTITY_HEADER" | jq -r .access_token
            else
                # Fallback: utiliser le contexte Azure CLI actuel
                az account get-access-token --resource https://ossrdbms-aad.database.windows.net --query accessToken --output tsv
            fi
            ;;
        "Group")
            # Pour un groupe AD, on utilise l'identité de l'utilisateur courant s'il est membre
            echo "Getting token for current user (must be member of admin group)..." >&2
            az account get-access-token --resource https://ossrdbms-aad.database.windows.net --query accessToken --output tsv
            ;;
        "User")
            # Pour un utilisateur AD
            echo "Getting token for current user..." >&2
            az account get-access-token --resource https://ossrdbms-aad.database.windows.net --query accessToken --output tsv
            ;;
        *)
            # Fallback par défaut (si PGADMINTYPE est vide ou non reconnu)
            echo "Getting token with default method..." >&2
            az account get-access-token --resource https://ossrdbms-aad.database.windows.net --query accessToken --output tsv
            ;;
    esac
}

# Obtenir le token approprié
export PGPASSWORD=$(get_admin_token "$PGADMINTYPE" "$PGADMINOBJECTID")

# Vérifier que le token est obtenu
if [ -z "$PGPASSWORD" ]; then
    echo "ERROR: Failed to obtain Entra ID token for admin type: $PGADMINTYPE"
    echo "Make sure you are authenticated with 'az login' and have the correct permissions"
    exit 1
fi

echo "Token obtained successfully. Creating Entra ID principals and setting permissions..."

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
    
    # Déterminer le type de principal (service pour MSI, group pour groupes AD, user pour utilisateurs)
    PRINCIPAL_TYPE="service"
    if [[ "$USERNAME" == *"@"* ]]; then
        PRINCIPAL_TYPE="user"
    fi
    
    # Créer le principal sur la base postgres
    PGDATABASE="postgres" psql -h "$PGHOST" -p "$PGPORT" -U "$PGADMINUSER" -c \
        "SELECT * FROM pgaadauth_create_principal_with_oid('$USERNAME', '$OBJECTID', '$PRINCIPAL_TYPE', false, false);" \
        2>&1 | tee /tmp/psql_output.log
    
    # Vérifier si le principal existe déjà (ignorer l'erreur)
    if grep -q "already exists\|duplicate" /tmp/psql_output.log 2>/dev/null; then
        echo "Principal $USERNAME already exists, continuing..."
    elif [ ${PIPESTATUS[0]} -ne 0 ]; then
        echo "Warning: Issue creating principal $USERNAME, it may already exist"
    else
        echo "Principal $USERNAME created successfully"
    fi
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
            echo "GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO \"$USERNAME\";" >> "$TEMP_SQL"
            echo "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO \"$USERNAME\";" >> "$TEMP_SQL"
            echo "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON SEQUENCES TO \"$USERNAME\";" >> "$TEMP_SQL"
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
            echo "GRANT CREATE ON SCHEMA public TO \"$USERNAME\";" >> "$TEMP_SQL"
            ;;
    esac
    
    # Custom grants si spécifiés
    if [ -n "$CUSTOMGRANT" ] && [ "$CUSTOMGRANT" != "" ]; then
        echo "-- Custom grants for $USERNAME" >> "$TEMP_SQL"
        echo "$CUSTOMGRANT" >> "$TEMP_SQL"
    fi
    
    echo "" >> "$TEMP_SQL"
done

# Afficher le contenu SQL pour debug (optionnel)
echo "--- SQL Commands to execute ---"
cat "$TEMP_SQL"
echo "--- End of SQL Commands ---"

# Exécuter toutes les commandes SQL
psql -h "$PGHOST" -p "$PGPORT" -U "$PGADMINUSER" -f "$TEMP_SQL"

# Vérifier le résultat
if [ $? -eq 0 ]; then
    echo "Permissions set successfully for all users on database $PGDATABASE"
else
    echo "ERROR: Failed to set permissions on database $PGDATABASE"
    rm -f "$TEMP_SQL"
    exit 1
fi

# Nettoyer
rm -f "$TEMP_SQL"
rm -f /tmp/psql_output.log

echo "Script completed successfully!"
