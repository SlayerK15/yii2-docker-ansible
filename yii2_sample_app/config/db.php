<?php
return [
    'class' => 'yii\db\Connection',
    'dsn' => 'mysql:host=' . (getenv('DB_HOST') ?: 'localhost') . ';dbname=' . (getenv('DB_NAME') ?: 'yii2db'),
    'username' => getenv('DB_USER') ?: 'yii2user',
    'password' => getenv('DB_PASSWORD') ?: 'yii2password',
    'charset' => 'utf8',
];