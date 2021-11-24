#!/usr/bin/env bash

exec /opt/pharo/pharo \
	/opt/app/Pharo.image \
  launchpad start superluminal-service-discovery \
	--retry-delay-in-ms=10000
