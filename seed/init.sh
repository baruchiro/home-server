#!/bin/bash
cd $(dirname "$0")
git clone git@github.com:baruchiro/Accounts.git --depth 1

cp Accounts/Dockerfile .
rm -rf Accounts

cp ~/.ssh/id_rsa .
