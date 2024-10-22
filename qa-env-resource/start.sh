#!/bin/sh
systemctl daemon-reload
chkconfig bsc on
service bsc restart