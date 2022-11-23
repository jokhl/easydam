// module.exports = {
//   test: /\.svelte(\.erb)?$/,
//   use: [{
//     loader: 'svelte-loader',
//     options: {
//       hotReload: false
//     }
//   }],
// }

const path = require('path')

module.exports = {
  resolve: {
    alias: {
      svelte: path.resolve('node_modules', 'svelte')
    },
    extensions: ['.mjs', '.js', '.svelte'],
    mainFields: ['svelte', 'browser', 'module', 'main']
  },
  module: {
    rules: [
      {
        test: /\.(html|svelte(\.erb)?)$/,
        use: 'svelte-loader'
      },
      {
        test: /node_modules\/svelte\/.*\.mjs$/,
        resolve: {
          fullySpecified: false
        }
      }
    ]
  }
}
