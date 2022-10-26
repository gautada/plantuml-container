# plantuml-container
A plant UML container for k8s

https://plantuml.com

https://github.com/plantuml/plantuml

This should be generated from DB

CREATE DATABASE architecture;

DROP TABLE IF EXISTS node_tag_map;
DROP TABLE IF EXISTS tags;
DROP TABLE IF EXISTS nodes;

CREATE TABLE tags (
 tag VARCHAR(50) PRIMARY KEY NOT NULL
);

CREATE TABLE nodes (
 alias VARCHAR(25) PRIMARY KEY NOT NULL,
 label VARCHAR(255) NOT NULL,
 type VARCHAR(255),
 description TEXT,
 sprite VARCHAR(255),
 link VARCHAR(255)
);

CREATE TABLE node_tag_map (
 node VARCHAR(25) NOT NULL,
 tag VARCHAR(50) NOT NULL,
 PRIMARY KEY (node, tag)
);

CREATE TABLE systems (
 alias VARCHAR(25) PRIMARY KEY NOT NULL,
 label VARCHAR(255) NOT NULL,
 type VARCHAR(25) NOT NULL,
 external BOOLEAN NOT NULL,
 description TEXT,
 sprite VARCHAR(255),
 link VARCHAR(255),
 role VARCHAR(25)
);

CREATE TABLE system_tag_map (
 system VARCHAR(25) NOT NULL,
 tag VARCHAR(50) NOT NULL,
 PRIMARY KEY (node, tag)
);

-- Physical Locations
INSERT INTO nodes VALUES ('HOME', 'Home', 'Location', 'This is a standard home location, i.e. a provate residence outside of a managed enterprise environment', NULL, NULL, NULL);

-- Profiles are virtual profiles for the network
INSERT INTO nodes VALUES ('PRF_ANT', 'Anthony', 'Profile', 'A virtual location for devices assigned to Anthony', NULL, NULL, 'HOME');

INSERT INTO nodes VALUES ('PRF_AUB', 'Aubrey', 'Profile', 'A virtual location for devices assigned to Aubrey', NULL, NULL, 'HOME');

INSERT INTO nodes VALUES ('PRF_CLSTR', 'Cluster', 'Profile', 'A virtual location for devices assigned to the k8s cluster', NULL, NULL, 'HOME');

INSERT INTO nodes VALUES ('PRF_DVCS', 'Devices', 'Profile', 'A virtual location for devices that are used exclusevely as IOT devices', NULL, NULL, 'HOME');

INSERT INTO nodes VALUES ('PRF_GUEST', 'Guest', 'Profile', 'A virtual location for devices not assigned to a member of the family', NULL, NULL, 'HOME');

INSERT INTO nodes VALUES ('PRF_WORK', 'Work', 'Profile', 'A virtual location for devices used for work purposes', NULL, NULL, 'HOME');
