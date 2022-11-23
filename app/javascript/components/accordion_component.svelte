<script>
  import { createEventDispatcher, onMount } from 'svelte'

  export let icon
  export let label
  export let maxHeight = 'max-h-16'
  export let isOpen = false
  export let className
  let contentElem, currentHeight
  const dispatch = createEventDispatcher()

  function handleClick (e) {
    isOpen = !isOpen
  }

  const resizeObserver = new ResizeObserver(entries => {
    let deltaHeight = entries[0].target.offsetHeight - currentHeight

    dispatch('childResize', {
      deltaHeight: deltaHeight
    })

    // We need to update the height so the sign of the next deltas
    // will show in which direction the change is happening.
    currentHeight = entries[0].target.offsetHeight
  })

  onMount(() => {
    currentHeight = contentElem.offsetHeight
    resizeObserver.observe(contentElem)
  })
</script>

<div class="flex items-center text-gray-600 font-semibold">
  <span class="icon icon-{icon} transition-all duration-150 transform-gpu origin-center text-lg" class:rotate-90={isOpen} on:click={handleClick}></span> 
  <span class="ml-2 text-xs">{label}</span>
</div>

<div class="transition-all duration-300 overflow-scroll {className} {isOpen ? maxHeight : ''}" class:max-h-0={!isOpen} bind:this={contentElem}>
  <slot />
</div>
