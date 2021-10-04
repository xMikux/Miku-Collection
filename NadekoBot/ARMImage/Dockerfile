FROM mcr.microsoft.com/dotnet/sdk:5.0-buster-slim-arm64v8 AS build
WORKDIR /source

COPY src/NadekoBot/*.csproj src/NadekoBot/
COPY src/NadekoBot.Coordinator/*.csproj src/NadekoBot.Coordinator/
COPY src/NadekoBot.Generators/*.csproj src/NadekoBot.Generators/
COPY src/ayu/Ayu.Discord.Voice/*.csproj src/ayu/Ayu.Discord.Voice/
RUN dotnet restore src/NadekoBot/

COPY . .
WORKDIR /source/src/NadekoBot
RUN set -xe; \
    dotnet --version; \
    dotnet publish -c Release -o /app --no-restore; \
    mv /app/data /app/data_init; \
    rm -Rf libopus* libsodium* opus.* runtimes/win* runtimes/osx* runtimes/linux-arm* runtimes/linux-mips*; \
    find /app -type f -exec chmod -x {} \; ;\
    chmod +x /app/NadekoBot; \
    apt-get install curl --no-install-recommends; \
    curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /app/youtube-dl

# final stage/image
FROM mcr.microsoft.com/dotnet/runtime:5.0-buster-slim-arm64v8
WORKDIR /app

COPY --from=build /app ./
COPY docker-entrypoint.sh /usr/local/sbin

RUN set -xe; \
    useradd -m nadeko; \
    apt-get update; \
    apt-get install -y libopus0 libsodium23 libsqlite3-0 ffmpeg sudo --no-install-recommends; \
    rm -rf /var/lib/apt/lists/*; \
    echo 'Defaults>nadeko env_keep+="ASPNETCORE_* DOTNET_* NadekoBot_* shard_id total_shards TZ"' > /etc/sudoers.d/nadeko; \
    mv /app/youtube-dl /usr/local/bin/youtube-dl; \
    chmod +x /usr/local/bin/youtube-dl; \
    chmod +x /usr/local/sbin/docker-entrypoint.sh

ENV shard_id=0
ENV total_shards=1

LABEL org.opencontainers.image.source https://github.com/xMikux/Miku-Collection

VOLUME [ "app/data" ]
ENTRYPOINT [ "/usr/local/sbin/docker-entrypoint.sh" ]
CMD dotnet NadekoBot.dll "$shard_id" "$total_shards"
