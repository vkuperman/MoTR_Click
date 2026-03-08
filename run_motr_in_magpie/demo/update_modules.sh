#!/bin/sh
rm -rf package-lock.json
rm -rf node_modules/magpie-base
npm install
npm run build
npm run serve
