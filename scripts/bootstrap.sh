#!/bin/bash
systemctl restart network.service
rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum -y makecache
yum -y upgrade
