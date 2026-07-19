# Use a lightweight Nginx web server
FROM --platform=linux/amd64 nginx:alpine

# Remove default static pages
RUN rm -rf /usr/share/nginx/html/*

# Copy compiled static website files from host dist/ folder
COPY dist/ /usr/share/nginx/html/

# Expose Nginx default HTTP port
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
