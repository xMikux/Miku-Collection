# OracleCLI

This image will rebuild every week, to make sure it will up-to-date!

## Usage

1. Make the oci config in ~/.oci/config or other location (but you need to change by yourself)

2. Add below line to your .profile:

   ```bash
   oci() { docker run --rm --mount type=bind,source=$HOME/.oci,target=/root/.oci ghcr.io/xmikux/miku-collection:oci-cli "$@"; }
   ```

3. Or you can just manual run by yourself:

* Normal Run

```cmd
docker run --rm -it -v ${HOME}/.oci:/root/.oci ghcr.io/xmikux/miku-collection:oci-cli -h
```

* Override entrypoint

```cmd
docker run --rm -it -v ${HOME}/.oci:/root/.oci --entrypoint bash ghcr.io/xmikux/miku-collection:oci-cli
```

### Reference source

* [stephenpearson/oci-cli](https://github.com/stephenpearson/oci-cli)
* [therealcmj/oci-cli-docker](https://github.com/therealcmj/oci-cli-docker)
