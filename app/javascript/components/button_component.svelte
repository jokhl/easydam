<script>
  export let className
  export let onClick
  export let label = ''
  export let icon
</script>

<button class="{className}" on:click={onClick}>
  {#if icon}
    <span class="mr-1 icon icon-{icon}"></span>
  {/if}
  {label}
  <slot />
</button>
