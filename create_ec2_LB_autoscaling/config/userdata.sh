#!/bin/bash

sudo yum install nginx -y
echo "<html>
<head>
        <title>Test Page for the Nginx HTTP Server on Red Hat Enterprise Linux</title>
</head>
    <body>
        <h1>Welcome to <strong>NginX</strong> on Red Hat Enterprise Linux!</h1>

                <h2>Created by <strong>Terraform</strong></h2>
    </body>
</html>
" > /usr/share/nginx/html/index.html
sudo systemctl start nginx
sudo systemctl enable nginx
