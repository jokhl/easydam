import App from '../app.svelte'

document.addEventListener('DOMContentLoaded', () => {
  const app = new App({
    target: document.body
  })

  window.app = app
})
