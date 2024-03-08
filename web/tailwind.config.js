const colors = require("tailwindcss/colors");
/** @type {import('tailwindcss').Config} */
export default {
  content: ["./index.html", "./src/**/*.{js,ts,jsx,tsx}"],
  theme: {
    extend: {},
    colors: {
      ...colors,
      "main-primary": "#0d6752",
      "dark-primary": "#17181e",
      "text-primary": "#c0bdbf",
    },
  },
  plugins: [],
};
