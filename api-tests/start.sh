#!/usr/bin/env bash

exec /opt/pharo/pharo \
	/opt/Superluminal-Service-Discovery-Example/Pharo.image \
	super-luminal-service-discovery \
    --message="${MESSAGE}" \
    --consul-agent-location="${CONSUL_AGENT_LOCATION}" \
		--retry-delay-in-ms=10000
