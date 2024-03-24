# AddameServer



4. Check for Configuration File Inside the Container
You can also directly check the contents of the /etc/nginx/conf.d directory
inside the container to ensure your configuration file is present:


docker exec addame_nginx_rp ls /etc/nginx/conf.d

And to inspect the contents of your configuration file (replace default.conf with your file name if different):

docker exec addame_nginx_rp cat /etc/nginx/conf.d/default.conf

If the configuration file is correctly placed and Nginx still doesn't seem to behave as expected,
review the configuration file for syntax errors or misconfigurations. 
You can use nginx -t inside the container to test the Nginx configuration for syntax correctness:


docker exec addame_nginx_rp nginx -t
