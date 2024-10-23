<?php
$db = pg_connect('host=127.0.0.1 port=5432 dbname=test_db user=tuser password=PassW0rdStr0ng');
$result = pg_query($db, "select * from test_tb");
$resultArr = pg_fetch_all($result);
print_r($resultArr);
?>