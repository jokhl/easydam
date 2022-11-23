const { webpackConfig, merge } = require('@rails/webpacker')
const svelteConfig = require('./loaders/svelte')
const CSSConfig = require('./loaders/css')

module.exports = merge(webpackConfig, svelteConfig, CSSConfig)
