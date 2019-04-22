#!/bin/bash

sudo systemctl stop httpd
sudo certbot renew
sudo systemctl start httpd

