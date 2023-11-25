/** @type {import('next').NextConfig} */
const runtimeCaching = require('next-pwa/cache');

const withPWA = require('next-pwa')({
  dest: 'public',
  disable: process.env.NODE_ENV === 'development',
  runtimeCaching,
});

module.exports = withPWA({
  //next.js config
  reactStrictMode: true,
  output: 'export',
  images: {
    unoptimized: true,
  },
  trailingSlash: true,
});

// const nextConfig = {
//   output: 'export',
//   images: {
//     unoptimized: true,
//   },
//   trailingSlash: true,
// };

// module.exports = nextConfig;
