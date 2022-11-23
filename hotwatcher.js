const chokidar = require('chokidar')

chokidar.watch('/Users/mokh/Downloads/Hot Folder').on('all', (event, path) => {
  console.log(event, path)
})
