<script>
  export let isVisible = false
  export let view
  export let props = {}
  export function toggle () {
    animate()
    isVisible = !isVisible
  }

  const initialCSS = isVisible ? 'max-h-screen' : 'max-h-0 overflow-hidden'

  let containerElem

  function animate () {
    if (isVisible) {
      containerElem.classList.remove('max-h-screen')
      containerElem.classList.add('max-h-0')
      containerElem.classList.add('overflow-hidden')
    } else {
      containerElem.classList.remove('max-h-0')
      containerElem.classList.add('max-h-screen')
      setTimeout(() => {
        containerElem.classList.remove('overflow-hidden')
      }, 500)
    }
  }

  function close () {
    if (isVisible) toggle()
  }
</script>

<div class="sticky top-0 z-10 w-full h-auto bg-white border-b transition-all duration-500 {initialCSS}" bind:this={containerElem}>
  <svelte:component this={view} {...props} isVisible={isVisible} on:close={close} />
</div>
