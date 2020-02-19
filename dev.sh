#!/bin/bash
set -ex

./cli-cloudformation-run.sh prom-test-$(date '+%a-%m-%d-%H%M') prometheus-cf.yml