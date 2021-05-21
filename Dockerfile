ARG NANOSERVER_VERSION=lts-nanoserver-1809
FROM mcr.microsoft.com/powershell:${NANOSERVER_VERSION} AS  build

LABEL \
    org.label-schema.name="NanoServer-MySQL" \
    org.label-schema.description="This image is an MySQL from Azul Systems® Zulu on NanoServer image." \
    org.label-schema.version="1.0.0" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.vendor="Hitoshi Kuroyanagi" \
    org.label-schema.url="https://www.azul.com/" \
    org.label-schema.maintainer.name="euledge" \
    org.label-schema.vcs-url="https://github.com/euledge/nanoserver-mysql"\
    org.label-schema.docker.cmd="docker run --name $CONTAINER -t -d nanoserver-mysql:latest" \
    org.label-schema.docker.params="OPENJDK_VERSION=version number"

ARG MYSQL_VERSION=8.0.24-winx64
SHELL ["pwsh", "-Command"]

RUN \
    if(!(Test-Path -Path 'C:\Temp')) \
    { \
    New-Item \
    -Path 'C:\Temp' \
    -ItemType Directory \
    -Verbose | Out-Null ; \
    } ;

RUN \
    Invoke-WebRequest \
    -Uri "https://downloads.mysql.com/archives/get/p/23/file/mysql-$ENV:MYSQL_VERSION.zip" \
    -OutFile "C:\\Temp\\mysql-$ENV:MYSQL_VERSION.zip" \
    -UseBasicParsing \
    -Verbose ; \
    \
    Expand-Archive \
    -Path "C:\\Temp\\mysql-$ENV:MYSQL_VERSION.zip" \
    -DestinationPath 'C:\Program Files' \
    -Verbose ;

USER USER ContainerAdministrator
RUN \
    Set-ItemProperty \
    -Path 'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Environment' \
    -Name 'MYSQL_HOME' \
    -Value $('C:\Program Files\mysql-' + $ENV:MYSQL_VERSION) \
    -Verbose ; \
    \
    Set-ItemProperty \
    -Path 'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Environment' \
    -Name 'Path' \
    -Value $($ENV:Path + ';C:\Program Files\mysql-' + $ENV:MYSQL_VERSION + '\bin') \
    -Verbose ;
USER ContainerUser

# Test application
RUN mysql -version

# Remove temporary items from the build image
RUN \
    Remove-Item \
    -Path 'C:\Temp' \
    -Recurse \
    -Verbose ;
