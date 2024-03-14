# PlantUML

FF

[PlantUML](https://plantuml.com) is used to draw UML diagrams, using a simple and human readable text description. It's more a drawing tool than a modeling tool.

This container is a [PlantUML Server](https://github.com/plantuml/plantuml-server) which provides the parser and rendering of plantuml -> various diagrams.

## Features

- **Encoding:** Converts the puml code to simple string.
- **Interactive:** Interface to write and refine diagrams.
- **Metadata:** A diagram's source code is saved in the generated PNG metadata 


### Encoding

Provides a standardized way to [encode diagram text description to a simple string of characters](https://plantuml.com/text-encoding) that contains only digits, letters, underscore and minus character. The goal of such an encoding is to facilitate communication of diagrams through URL (see server). This encoding includes compression to keep encoded strings as short as possible.

### Interactive

The web [interface provides](https://plantuml.com/server) input field is used to enter your diagram description. You can type in any diagram description, then press the submit button and the diagram will be displayed below. It's a good practice to start your diagram by the @startxxx keyword.

When you validate the diagram, you are redirected to an encoded URL encoding your diagram. The encoded form is a convenient way to share your diagrams with others because it's shorter than the many lines of a diagram and it can be easily displayed in a browser using the online PlantUML Server.

For example, `SyfFKj2rKt3CoKnELR1Io4ZDoSa70000` is the encoded form of:
```
@startuml
Bob -> Alice : hello
@enduml
```

### Metadata

PlantUML saves the diagram's source code in the generated PNG Metadata in the form of encoded text. So it is possible to retrieve this source by using the query parameter metadata, giving it some image URL.

For example, if you want to retrieve the diagram source of the image `http://i.stack.imgur.com/HJvKF.png` use the following server request: `http://www.plantuml.com/plantuml/?metadata=http://i.stack.imgur.com/HJvKF.png`.



https://github.com/plantuml/plantuml
Actual project is plantuml-server: https://github.com/plantuml/plantuml-server
The server includes the [stdlib](https://github.com/plantuml/plantuml-stdlib) which can be accessed via `!include <...>`  

PlantUML is based on Tomcat and should specify the specific build for tomcat.
- https://www.middlewareinventory.com/blog/docker-tomcat-example-dockerfile-sample/
- https://dlcdn.apache.org/tomcat/tomcat-10/
- https://tomcat.apache.org

## Development

### Build

#### Version Arguments

1. Container Base - Alpine Linux: [ALPINE_VERSION](https://hub.docker.com/repository/registry-1.docker.io/gautada/alpine/tags?page=1&ordering=last_updated) 
2. Code - PlantUML Server: [PLANTUML_SERVER_VERSION](https://github.com/plantuml/plantuml-server/tags)
3. Supporting - Tomcat Server: [TOMCAT_VERSION](https://dlcdn.apache.org/tomcat/tomcat-10)

## Architecture

### Context

![Context Diagram](https://www.plantuml.com/plantuml/svg/VLB1JiCm3BtlAqp5OKYekt12W0HR1PKOLErsdhBKQoFIf8fT1dzFqcrQOS0fZkttdb-SCsMaxag4c-dLP7eLjrsZxqPdtxEhgJMC7xolZZ9qPCquMXP97br2j2HquNmGf2JG9p4sqFaa60kYuneDAobOMHDTZ8g-lae-U1pDNsV9Su3EROaw1FTErefHTWwXJy9Ci5WBGbyzrygytKOrSqlNaub4JHt5bPTGw69jfT0_18eiJnT94PYBrdbY6efmK4cbDL2WU-zD_92W7UWFZN6KFT-_B9RptaEcXU5zF5EL4ysU5ZRMGL8gLgO2OKgeqA0J_TLkG0odAPK8I3eTfGtqVW7_-drC5q_BXp31e-AwMuTewfyHScmjARRkyvHvkzt6LTyUIzjunb6EUh2SeSa2JKcxpVZ6lk_m3OPjgVymJaWcs7fYcErS7H3V28yRod633er4WhGH5VxMVZIOTMkjgCRom3xkGHU_eOvMJa29aTvCwM5V)

```
@startuml
!include <C4/C4.puml>
!include <C4/C4_Context.puml>

Person("USER", "User", "Basic system user no authentication")
System_Ext("MODEL", "Model", "Architecure Model Database", $link="https://celsus.gautier.local")
System_Ext("SPRITES", "Sprites", "Architecture Icon Server", $link="https://sprites.gautier.local")
System("PLANTUML", "PlantUML", "Digram Server for Editing and generating of architecture diagrams", $link="https://plantuml.gautier.local")
System_Ext("GITHUB", "Github", "Code Repository", $link="https://www.github.com")

Rel("MODEL", "PLANTUML", "Sends Model")
Rel("USER", "PLANTUML", "Interacts with Diagram")
Rel("PLANTUML", "SPRITES", "References Image")
Rel("PLANTUML", "GITHUB", "Published Diagram(Image)")
Rel("PLANTUML", "MODEL", "Published Diagram(Encoded)")
@enduml
```
