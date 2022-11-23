<script>
  import { onMount } from 'svelte'

  export let menu

  let contextMenuElem
  let parentElement
  let isOpen = false

  onMount(() => {
    parentElement = contextMenuElem.parentElement
    parentElement.addEventListener('contextmenu', onMenuOpen)
    
    // If the context menu is already open and the user drags somewhere else,
    // a 'click' event won't be triggered until the user releases the mouse.
    // That's why we need to use the 'mousedown' event instead.
    window.addEventListener('mousedown', onWindowClick)
  })

  function onMenuOpen (e) {
    e.preventDefault()
    const position = getPosition(e)
    contextMenuElem.style.left = `${position.x}px`
    contextMenuElem.style.top = `${position.y}px`
    showMenu()
  }

  function onWindowClick (e) {
    if (isOpen && !contextMenuElem.contains(e.target)) hideMenu()
  }

  function getPosition (e) {
    let posX = e.pageX + parentElement.scrollLeft - 
      parentElement.getBoundingClientRect().left
    let posY = e.pageY + parentElement.scrollTop - 
      parentElement.getBoundingClientRect().top

    // If the context menu overflows the parent element, show it on the opposite
    // side.
    if (posX > parentElement.offsetWidth - contextMenuElem.offsetWidth) {
      posX -= contextMenuElem.offsetWidth
    }
    if (posY > parentElement.offsetHeight - contextMenuElem.offsetHeight) {
      posY -= contextMenuElem.offsetHeight
    }

    return {
      x: posX,
      y: posY
    }
  }

  function hideMenu () {
    contextMenuElem.classList.add('hidden')
    isOpen = false
  }

  function showMenu () {
    contextMenuElem.classList.remove('hidden')
    isOpen = true
  }
</script>

<div class="hidden absolute z-50" bind:this={contextMenuElem}>
  <ul class="py-1 bg-theme-light-gray rounded-md shadow-md-2 select-none">
    {#each menu as item}
      <li class="py-0.5 px-4 hover:bg-blue-500 text-sm text-gray-700 hover:text-gray-50" on:click={item.callback}>
        {item.title}
      </li>
    {/each}
  </ul>
</div>
