<?php
$mysql = new mysqli($_ENV['WP_DB_HOST'], 'root', $_ENV['MYSQL_ENV_MYSQL_ROOT_PASSWORD'], '', $_ENV['WP_DB_PORT']);
$mysql->multi_query(<<<EOSQL
CREATE DATABASE IF NOT EXISTS ${_ENV['WP_DB_NAME']};
GRANT ALL PRIVILEGES ON ${_ENV['WP_DB_NAME']}.* TO "${_ENV['WP_DB_USER']}" IDENTIFIED BY "${_ENV['WP_DB_PASSWORD']}";
FLUSH PRIVILEGES;
EOSQL) 

var_dump($mysql->errno, $mysql->error);

do {
    if ($res = $mysqli->store_result()) {
        var_dump($res->fetch_all(MYSQLI_ASSOC));
        $res->free();
    }
} while ($mysqli->more_results() && $mysqli->next_result());
