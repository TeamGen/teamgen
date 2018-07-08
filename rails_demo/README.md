# rails_demo

## To Run
```
docker build -t rails_demo .
docker run -it --rm --name my-running-script -v "$PWD":/usr/src/myapp -w /usr/src/myapp ruby:2.5 ruby main.rb
```
