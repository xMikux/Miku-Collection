FROM python:3.9-slim as Builder

COPY requirements.txt .

RUN pip install --no-cache-dir --user -r requirements.txt

FROM python:3.9-alpine

COPY --from=Builder /root/.local /root/.local

ENV PATH=/root/.local/bin:$PATH

RUN yes | oci setup autocomplete

LABEL org.opencontainers.image.source https://github.com/xMikux/Miku-Collection \
      org.opencontainers.image.authors=Efi

ENTRYPOINT [ "oci" ]