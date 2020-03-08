sed -i s/127.0.0.1:9000/php-fpm.openebs.svc.cluster.local:9000/g /etc/nginx/nginx.conf && service nginx stop && service nginx reload && service nginx start &
echo "PHP-FPM scaled successfully. Please run php-fpm-sync.sh from kubemaster and scale php-fpm pods"
