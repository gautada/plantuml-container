# PlantUML

[PlantUML](https://plantuml.com) is used to draw UML diagrams, using a simple and human readable text description. It's more a drawing tool than a modeling tool.

This container is a [PlantUML Server](https://github.com/plantuml/plantuml-server) which provides the parser and rendering of plantuml -> various diagrams.



https://github.com/plantuml/plantuml
Actual project is plantuml-server: https://github.com/plantuml/plantuml-server
The server includes the [stdlib](https://github.com/plantuml/plantuml-stdlib) which can be accessed via `!include <...>`  

PlantUML is based on Tomcat and should specify the specific build for tomcat.
- https://www.middlewareinventory.com/blog/docker-tomcat-example-dockerfile-sample/
- https://dlcdn.apache.org/tomcat/tomcat-10/
- https://tomcat.apache.org

## Development

### Build

docker build --build-arg ALPINE_VERSION=3.16.2 --build-arg PLANTUML_VERSION=1.2022.7 --build-arg TOMCAT_VERSION=10.0.27 --file Containerfile --label revision="$(git rev-parse HEAD)" --label version="$(date +%Y.%m.%d)" --no-cache --tag plantuml:build .

### Run

docker run --interactive --tty --name plantuml-manual --publish 8080:8080 --rm plantuml:build



