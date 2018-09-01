#!/bin/bash
set -ex

DEBIAN_FRONTEND=noninteractive apt update
DEBIAN_FRONTEND=noninteractive apt upgrade -y
