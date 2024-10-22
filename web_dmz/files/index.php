<?php
$db = pg_connect('host=127.0.0.1 port=5432 dbname=test_db user=tuser password=super_str0ng_pa$$word');
$result = pg_query($db, "select * from test_tb");
$resultArr = pg_fetch_all($result);
print_r($resultArr);
?>