FROM nginx

# Copy nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy website files
COPY www/ /usr/share/nginx/html/