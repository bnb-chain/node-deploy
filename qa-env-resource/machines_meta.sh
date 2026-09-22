#!/usr/bin/env bash

validator_ips_comma=""
sentry_ips_comma=""
fullnode_ips_comma=""
declare -A ips2ids

# Private IP -> public IP for each validator's MEV sentry.
# Missing or empty entries fall back to the validator's private IP.
declare -A ips2publicips
