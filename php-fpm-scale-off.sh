sed -i s/php-fpm.openebs.svc.cluster.local:9000/127.0.0.1:9000/g /etc/nginx/nginx.conf && service nginx stop && service nginx reload && service nginx start &
echo "PHP-FPM switched to localhost successfully"
