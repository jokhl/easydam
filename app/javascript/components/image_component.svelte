<script>
  import { onMount, onDestroy, createEventDispatcher } from 'svelte'
  export let src = ''
  export let alt = ''
  export let className = ''
  export let preventBrowserDragging = false
  export let transitionFunction = function () {}
  export let transitionParams = {}

  const dispatch = createEventDispatcher()

  let imgElem
  let isMounted = false
  let isLoaded = false

  $: handleSrcChange(src)

  onMount(() => {
    imgElem.addEventListener('load', handleOnLoad)
    imgElem.src = src
    isMounted = true

    if (preventBrowserDragging) {
      imgElem.addEventListener('mousedown', e => e.preventDefault())
    }
  })

  onDestroy(() => {
    imgElem.removeEventListener('load', handleOnLoad)
    
    if (preventBrowserDragging) {
      imgElem.removeEventListener('mousedown', e => e.preventDefault())
    }
  })

  function handleSrcChange () {
    if (isMounted) {
      isLoaded = false
      imgElem.src = src
    }
  }

  function handleOnLoad () {
    isLoaded = true
    dispatch('imageLoaded', { imgElem: imgElem })
  }
</script>

{#if !isLoaded}
  <div class="bg-gray-600 rounded-md"></div>
{/if}

<img src="" class="{className}" in:transitionFunction={transitionParams} alt="{alt}" bind:this={imgElem}>
