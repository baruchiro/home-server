BACKUP_DIR=$1
mkdir -p ${BACKUP_DIR}

TABLE_NAMES=$(mysqlsh --user=${MYSQL_USER} --password=${MYSQL_PASSWORD} --database=nocobase --sql -e "SELECT name FROM collections")

for TABLE in ${TABLE_NAMES}; do
  if [ "$TABLE" != "name" ]; then
    mysqlsh --user=${MYSQL_USER} --password=${MYSQL_PASSWORD} --database=nocobase --sql -e "SELECT * FROM ${TABLE}" --result-format=json > ${BACKUP_DIR}/${TABLE}.json
  fi
done

echo -e "\033[1;34mBackup complete!\033[0m"
