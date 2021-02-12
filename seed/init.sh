#!/bin/bash
cd $(dirname "$0")
git clone git@github.com:baruchiro/Accounts.git

cp Accounts/Dockerfile .
rm -rf Accounts

cp ~/.ssh/id_rsa .
