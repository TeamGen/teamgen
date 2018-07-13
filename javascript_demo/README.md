# config_builder

## To Run
```
docker build -t config_builder .
docker run -it --rm --name my-running-script -v "$PWD":/usr/src/myapp -w /usr/src/myapp node:latest node index.js
```
