# Stage 1: Load the project
FROM ghcr.io/ba-st/pharo-loader:v11.0.0 AS loader

COPY --chown=pharo:users ./source /opt/pharo/source
COPY --chown=pharo:users ./.git /opt/pharo/.git
RUN pharo metacello install gitlocal://. BaselineOfSuperluminal --groups=Examples

# Stage 2: Copy the resulting Pharo.image with our project loaded
# into a new docker image with just the vm
FROM ghcr.io/ba-st/launchpad:v5

COPY --from=loader --chown=pharo:users /opt/pharo/Pharo.image ./
COPY --from=loader --chown=pharo:users /opt/pharo/Pharo*.sources ./

RUN mkdir logs

CMD ["launchpad-start", "superluminal-service-discovery", "--retry-delay-in-ms=10000"]
