<script>
  import { register, activeRoute } from './router.svelte'

  export let path = '*'
  export let view = null
  export let redirect
  export let props = {}

  let params = {}

  register({ path, view, redirect })

  $: if ($activeRoute.path === path) {
    params = $activeRoute.params
  }
</script>

{#if $activeRoute.path === path}
  <svelte:component this={view} {...props} {...params} />
  <slot />
{/if}
