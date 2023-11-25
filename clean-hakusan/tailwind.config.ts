import type { Config } from 'tailwindcss';

const config: Config = {
  content: [
    './src/pages/**/*.{js,ts,jsx,tsx,mdx}',
    './src/components/**/*.{js,ts,jsx,tsx,mdx}',
    './src/app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        main: '#428cee',
      },
      backgroundImage: {
        'gradient-radial': 'radial-gradient(var(--tw-gradient-stops))',
        'gradient-conic': 'conic-gradient(from 180deg at 50% 50%, var(--tw-gradient-stops))',
        select: 'url(/image/arrow.png),linear-gradient(to bottom, #fff 0%, #efebe1 100%)',
      },
      spacing: {
        iphone: 'env(safe-area-inset-bottom, 20px)',
      },
    },
  },
  plugins: [],
};
export default config;
