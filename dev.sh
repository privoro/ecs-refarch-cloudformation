#!/bin/bash
set -ex

# DEV WORKFLOW FOR STACK CREATION + TEST

./cli-cloudformation-run.sh prom-test-$(date '+%a-%m-%d-%H%M') prometheus-cf.yml