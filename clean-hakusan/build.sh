#!/bin/sh
npm run build
rm -rf ../public/_next
rm ../public/workbox*
shopt -s dotglob
cp -rf out/ ../public/
cp -f .next/app-build-manifest.json ../public/
