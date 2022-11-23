<script>
  import { fly } from 'svelte/transition'

  export let view
  export let isOpen = false
  export let props = {}
  export let className
</script>

{#if isOpen}
  <div class="absolute z-10 mt-2 bg-white border rounded-lg shadow-lg {className}" transition:fly={{ y: -10, opacity: 0, duration: 300 }}>
    <svelte:component this={view} {...props} />
  </div>
{/if}
