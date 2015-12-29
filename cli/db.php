<?php

$tries = 10;
$delay = 3;

// Connect as the root user
do {
	@$mysqli = new mysqli($_ENV['WP_DB_HOST'], 'root', $_ENV['MYSQL_ROOT_PASSWORD'], '', $_ENV['WP_DB_PORT']);
	// If the RDBMS isn't ready yet, wait and try again
	if ($mysqli->connect_errno) {
		--$tries;
		error_log("{$mysqli->connect_errno}: {$mysqli->connect_error}");
		if ($tries <= 0)
			exit(1);
		sleep($delay);
	}
} while ($mysqli->connect_errno);

// Create the new DB and user, grant privileges
$mysqli->multi_query(<<<EOSQL
CREATE DATABASE IF NOT EXISTS {$_ENV['WP_DB_NAME']};
GRANT ALL PRIVILEGES ON {$_ENV['WP_DB_NAME']}.* TO "{$_ENV['WP_DB_USER']}" IDENTIFIED BY "{$_ENV['WP_DB_PASSWORD']}";
FLUSH PRIVILEGES;
SHOW GRANTS FOR "{$_ENV['WP_DB_USER']}";
EOSQL
);

if ($mysqli->errno)
	die("{$mysqli->errno}: {$mysqli->error}");

do {
    if ($res = $mysqli->store_result()) {
        foreach ($res->fetch_all() as $row)
        	print implode("\t", $row) . PHP_EOL;
        $res->free();
    }
} while ($mysqli->more_results() && $mysqli->next_result());
