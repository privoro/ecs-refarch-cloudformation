#!/bin/bash
set -ex

# DEV WORKFLOW FOR STACK CREATION + TEST

./cli-cloudformation-run.sh prometheus-ecs-$(date '+%a-%m-%d-%H%M') prometheus-cf.yml