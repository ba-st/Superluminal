# Stage 1: Load the project
FROM basmalltalk/pharo:8.0-image AS loader
ARG BRANCH_NAME=release-candidate
ENV BRANCH_NAME=$BRANCH_NAME
COPY load-project.st ./
RUN pharo Pharo.image load-project.st --save --quit

# Stage 2: Copy the resulting Pharo.image with our project loaded
# into a new docker image with just the vm
FROM basmalltalk/pharo:8.0

USER root

WORKDIR /opt/Superluminal-Service-Discovery-Example
COPY start.sh ./
COPY --from=loader /opt/pharo/Pharo.image ./
COPY --from=loader /opt/pharo/Pharo.changes ./
COPY --from=loader /opt/pharo/Pharo*.sources ./

RUN mkdir logs \
  && chmod a+x start.sh \
  && chown --recursive pharo:users /opt/Superluminal-Service-Discovery-Example

USER pharo

CMD ["./start.sh"]
