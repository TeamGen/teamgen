# teamgen

## To Run
```
docker build -t teamgen .
docker run -it --rm --name my-running-script -v "$PWD":/usr/src/myapp -w /usr/src/myapp ruby:2.5 ruby teamgen.rb
```
