### docker run commands

#### create storage

```
```
docker volume create pyvim_home
docker volume create pyvim_plugins

```
```
#### build image

```
docker build -f pyvim_manual -t pyvim:manual .
```

#### create container

```
docker run --rm -it \                         
  -v pyvim_home:/home/appuser \
  -v "pyvim_plugins:/home/appuser/.config/nvim/lua/plugins" \
  -p 3000:3000 \
  pyvim:manual \
  /bin/bash
```

