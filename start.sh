#!/bin/sh

set -eu

PUBSUB_PORT="${PUBSUB_PORT:-"8085"}"

exec gcloud beta emulators pubsub start --host-port="0.0.0.0:$PUBSUB_PORT"
