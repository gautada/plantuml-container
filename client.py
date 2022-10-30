import requests
from urllib.parse import urlparse
from pathlib import Path

url = 'http://192.168.1.5:8080/form'
data = {'text': """
@startuml
!include <C4/C4.puml>
!include <C4/C4_Context.puml>

Boundary("B1", "Upstream") {
 System("UP1", "Upstream01")
 System("UP2", "Upstream02")
 System("UP3", "Upstream03")
 Lay_D("UP1", "UP2")
 Lay_D("UP2", "UP3")
}

System("TARGET", "Target")
@enduml
"""}

x = requests.post(url, data=data)
# print(x.text)
# print(x.status_code)
# print(x.headers)
# print(x.url)
uri = urlparse(x.url)
# print(uri.path)
path = Path(uri.path)
print(path.name)
