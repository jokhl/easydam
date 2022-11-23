<script>
  import { activeRoute } from '../router.svelte'

  export let href, className

  let highlightingCondition = false
  
  // All routes start with '/' so for this case, we check if the link
  // is exactly this path only.
  $: if (href === '/') {
    highlightingCondition = $activeRoute.path === href
  } else {
    highlightingCondition = $activeRoute.path && 
      $activeRoute.path.startsWith(href)
  }
</script>

<a href={href} class={className} class:active={highlightingCondition}>
  <slot />
</a>
