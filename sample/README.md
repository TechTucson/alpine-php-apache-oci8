# Sample Usage
This docker file will create an image using the Docker Hub image as our base. It will then
- Move index.php into info.php
- Add the following files /apache/index.html /apache/clouds.jpg over to /var/www/html/public
## To build this image
docker -t build test .
## To run this container 
docker run -d --name app1 -p 8090:80 test
## Verify 
https://localhost:8090
### Check PHP Info
https://localhost:8090/info.php
