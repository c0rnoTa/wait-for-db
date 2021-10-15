#!/usr/bin/env sh

check_mysql() {
    echo "INFO Check MySQL server availability for '$DB_BOOTSTRAP_TIMEOUT' seconds"
    while [[ "$DB_BOOTSTRAP_TIMEOUT" -gt 0 ]]; do
        mysql -h $DB_HOST -P $DB_PORT -u $DB_USERNAME -p$DB_PASSWORD -e 'SELECT 1;' $DB_DATABASE
        [[ "$?" -eq 0 ]] && return 0
        DB_BOOTSTRAP_TIMEOUT=$((DB_BOOTSTRAP_TIMEOUT-1))
        sleep 1
    done

    return 1
}

check_pgsql() {
    echo "INFO Check PostgreSQL server availability for '$DB_BOOTSTRAP_TIMEOUT' seconds"

    while [[ "$DB_BOOTSTRAP_TIMEOUT" -gt 0 ]]; do
        PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT $DB_DATABASE $DB_USERNAME -c 'SELECT 1;'
        [[ "$?" -eq 0 ]] && return 0
        DB_BOOTSTRAP_TIMEOUT=$((DB_BOOTSTRAP_TIMEOUT-1))
        sleep 1
    done

    return 1
}

run_configCache() {
    echo "INFO Caching current configuration"
    php artisan config:cache
}

run_migrate() {
    echo "INFO Rolling up database migrate"
    php artisan migrate -n --force
}

run_swoole() {
    echo "INFO Running Swoole"
    php -d variables_order=EGPCS artisan octane:start --server=swoole --host=0.0.0.0 --port=9501
}

if [[ $# -eq 0 ]]; then
    # Аргументы переданы не были
    echo "INFO Starting entrypoint"

    [[ -z "$DB_CONNECTION" ]] && echo 'INFO DB_CONNECTION variable is not defined. Using default DB_CONNECTION=mysql' && export DB_CONNECTION=mysql
    [[ -z "$DB_DATABASE" ]] && echo 'INFO DB_DATABASE variable is not defined. Using default DB_DATABASE=laravel' && export DB_DATABASE=laravel
    [[ -z "$DB_USERNAME" ]] && echo 'INFO DB_USERNAME variable is not defined. Using default DB_USERNAME=revo' && export DB_USERNAME=revo
    [[ -z "$DB_PASSWORD" ]] && echo 'INFO DB_PASSWORD variable is not defined. Using default DB_PASSWORD=pass' && export DB_PASSWORD=pass
    [[ -z "$DB_BOOTSTRAP_TIMEOUT" ]] && echo 'INFO DB_BOOTSTRAP_TIMEOUT variable is not defined. Using default DB_BOOTSTRAP_TIMEOUT=120' && export DB_BOOTSTRAP_TIMEOUT=120

    if [[ "$DB_CONNECTION" == "mysql" ]]; then
        [[ -z "$DB_HOST" ]] && echo 'INFO DB_HOST variable is not defined. Using default DB_HOST=mysql' && export DB_HOST=mysql
        [[ -z "$DB_PORT" ]] && echo 'INFO DB_PORT variable is not defined. Using default DB_PORT=3306' && export DB_PORT=3306
        if ! check_mysql; then echo "ERROR check mysql connection"; exit 1; fi
    fi

    if [[ "$DB_CONNECTION" == "pgsql" ]]; then
        [[ -z "$DB_HOST" ]] && echo 'INFO DB_HOST variable is not defined. Using default DB_HOST=pgsql' && export DB_HOST=pgsql
        [[ -z "$DB_PORT" ]] && echo 'INFO DB_PORT variable is not defined. Using default DB_PORT=5432' && export DB_PORT=5432
        if ! check_pgsql; then echo "ERROR check pgsql connection"; exit 1; fi
    fi

    run_configCache
    run_migrate
    run_swoole
else
    # Запустить аргументы, переданные скрипту
    "$@"
fi
