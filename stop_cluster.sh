#!/bin/bash
ps -ef | grep geth | grep mine | awk '{print $2}' | xargs kill
