#! /bin/sh
INIT_FLAG_FILE=/data/db/init-completed
INIT_LOG_FILE=/data/db/init-mongod.INIT_LOG_FILE

start_mongod_as_daemon(){
echo
echo "> start monod ..."
echo
mongod \
    --fork \
    --quiet \
    --bind_ip 127.0.0.1 \
    --smallfiles;
}

create_user(){
echo
echo "> create user ..."

if [ ! "$MONGO_INITDB_ROOT_USERNAME" ] || [! "$MONGO_INITDB_ROOT_PASSWORD" ]; then
    return
fi
mongo "${MONOGO_INITDB_DATABASE}" <<-EOS
    db.createUser({
        user: "${MONGO_INITDB_ROOT_USERNAME},
        pwd: "${MONGO_INITDB_ROOT_USERNAME}",
        roles: [{ role: "root", db: "${MONGO_INITDB_DATABASE:-admin}"}]
        })
EOS

}

create_initialize_flag(){
echo
echo "> create initialize flag file ..."
echo
cat << -EOF > "${INIT_FLAG_FILE}"
[$(date +%Y-%m-%dT%H:M5S.%3N)] Initialize scripts if finigshed.
EOF
}

stop_method(){
echo
echo "> stop mongod ..."
echo
mongod --shutdown
}

if [ ! -e ${INIT_LOG_FILE} ]; then
    echo
    echo "--- INItialize MongoDB ---"
    echo
    start_mongod_as_daemon
    create_user
    create_initialize_flag
    stop_method
INIT_LOG_FILE

exec "$@"

