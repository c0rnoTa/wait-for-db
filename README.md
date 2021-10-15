## Wait for database

It's wait till database was initialized, but not only TCP socket open.
Script tries to connect to database and run `SELECT 1;` request there.

### Supports only
* MySQL
* PostgreSQL

### Run options

It uses native variables fot MySQL and PostgreSQL official containers:

* **DB_CONNECTION**- Database connection type. Could be `mysql` (default) or `pgsql`
* **DB_DATABASE** - Database name. Default is `laravel`
* **DB_USERNAME** - Username 
* **DB_PASSWORD** - Password
* **DB_BOOTSTRAP_TIMEOUT** - Number of retries to wait till database UP. It will try to connect each second. Default is 120 seconds.  
* **DB_HOST** - Database hostname. Default is `mysql` for MySQL and `pgsql` for PostgreSQL
* **DB_PORT** - Database port. Default is `3306` for MySQL and `5432` for PostgreSQL