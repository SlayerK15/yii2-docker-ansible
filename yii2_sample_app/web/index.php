<?php

// Production-ready entry point that reads from environment variables
// Read YII_DEBUG from environment variable, default to false for production
$yiiDebug = filter_var(getenv('YII_DEBUG'), FILTER_VALIDATE_BOOLEAN, FILTER_NULL_ON_FAILURE);
defined('YII_DEBUG') or define('YII_DEBUG', $yiiDebug !== null ? $yiiDebug : false);

// Read YII_ENV from environment variable, default to 'prod' for production
$yiiEnv = getenv('YII_ENV');
defined('YII_ENV') or define('YII_ENV', $yiiEnv ?: 'prod');

require __DIR__ . '/../vendor/autoload.php';
require __DIR__ . '/../vendor/yiisoft/yii2/Yii.php';

$config = require __DIR__ . '/../config/web.php';

(new yii\web\Application($config))->run();