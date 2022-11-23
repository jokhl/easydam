const colors = require('tailwindcss/colors')

module.exports = {
  darkMode: false, // or 'media' or 'class'
  theme: {
    extend: {
      colors: {
        theme: {
          'light-gray': '#f5f5f4'
        },
        gray: colors.trueGray
      }
    }
  },
  variants: {
    extend: {
      flex: ['group-hover'],
      display: ['group-hover'],
      backgroundColor: ['active'],
      textColor: ['active'],
      outline: ['active'],
      ringWidth: ['group-focus']
    }
  },
  plugins: []
}
