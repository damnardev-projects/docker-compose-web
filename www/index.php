<html>
    <head>
        <title>Docker Compose NGINX + PHP</title>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="icon" type="image/x-icon" href="/favicon.ico">
        <link rel="stylesheet" href="/styles.css">
    </head>
    <body>
        <article>
            <h1>Docker Compose NGINX + PHP</h1>
            <div>
                <p>Current server time is: <?php echo date('Y-m-d H:i:s'); ?></p>
                <p>Current server Timezone is: <?php echo date_default_timezone_get(); ?></p>
                <p>Current PHP script name is: <?php echo $_SERVER['SCRIPT_NAME']; ?></p>
            </div>
            <p>PHP Version: <?php echo phpversion(); ?></p>
        </article>
    </body>
</html>