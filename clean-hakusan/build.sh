#!/bin/sh
npm run build
rm -rf ../public/_next
cp -r out/ ../public/
