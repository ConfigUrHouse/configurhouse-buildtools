# Configurhouse theia

## Launch

To launch the docker containing the theia made for configurhouse
```bash
docker run -it --init -p 3000:3000 -p 8083:8083 -p 8084:8084 -v "$(pwd):/home/project:cached" wilmaxys/configurhouse-theia
```

## Fetch configurhouse projects

Fetch and install both projects for configurhouse

```bash
sh /home/ressources/fetch.sh
```

> You need to be in the docker with the terminal in theia or with docker exec