<script context="module">
  import { writable } from 'svelte/store'
  import { pageTitleStore } from './stores'

  const routes = {}
  export const activeRoute = writable({})

  export function register(route) {
    routes[route.path] = route
  }
</script>

<script>
  import { onMount, onDestroy } from 'svelte'
  import page from 'page'

  function setupPage () {
    for (let [path, route] of Object.entries(routes)) {
      page(path, (ctx) => {
        if (route.redirect) page.redirect(route.redirect)
        else $activeRoute = { ...route, params: ctx.params }
      })
    }

    page.start()

    // Triggered when user exits a page
    page.exit((ctx, next) => {
      $pageTitleStore = '' // reset the page title
      next()
    })
  }

  onMount(setupPage)
  onDestroy(page.stop)
</script>

<slot />
