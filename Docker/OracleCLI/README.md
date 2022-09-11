# OracleCLI

This image will rebuild every week, to make sure it will up-to-date!

## Usage

1. Make the oci config in ~/.oci/config or other location (but you need to change by yourself)

2. Add below line to your .profile:

   ```bash
   oci() { docker run --rm --mount type=bind,source=$HOME/.oci,target=/root/.oci ghcr.io/xmikux/oci-cli:latest "$@"; }
   ```

3. Or you can just manual run by yourself:

* Normal Run

```cmd
docker run --rm -it -v ${HOME}/.oci:/root/.oci ghcr.io/xmikux/oci-cli:latest -h
```

* Override entrypoint

```cmd
docker run --rm -it -v ${HOME}/.oci:/root/.oci --entrypoint bash ghcr.io/xmikux/oci-cli:latest
```

### Reference source

* [stephenpearson/oci-cli](https://github.com/stephenpearson/oci-cli)
* [therealcmj/oci-cli-docker](https://github.com/therealcmj/oci-cli-docker)
