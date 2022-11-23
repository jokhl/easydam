<script>
  import { onMount, onDestroy } from 'svelte'
  import { reveal } from '../transitions/reveal'

  export let className = ''
  export let collection = []
  export let value = ''
  export let selectedItem
  export let isOpen = false
  export let editable = false
  export let resetable = false
  export let emptyCollectionMessage = 'Sorry, no items to show.'
  export let placeholder = ''

  export function selectItem (idx) {
    handleItemSelection(idx)
  }

  export function open () {
    if (!isOpen) toggle()
  }

  export function close () {
    if (isOpen) toggle()
  }

  let listElem = { children: [] }
  let hoverIdx
  let inputContainerElem
  let icon
  let initialCollection = collection

  onMount(() => {
    window.addEventListener('click', handleWindowClick)
  })

  onDestroy(() => {
    window.removeEventListener('click', handleWindowClick)
  })

  function handleItemSelection (idx) {
    if (collection[idx]) {
      hoverIdx = idx
      selectedItem = collection[idx]
      value = selectedItem.value
      icon = selectedItem.icon

      // We don't want to permit resetting of initially non-editable inputs.
      if (editable) {
        editable = false
        resetable = true
      }

      close()
    }
  }

  function toggle () {
    if (collection === undefined || collection.length === 0) {
      if (!editable) {
        alert(emptyCollectionMessage)
      }
    } else {
      isOpen = !isOpen
    }
  }

  function handleKeyUp (e) {
    // This needs to be in handleKeyUp otherwise the 'close' function will
    // not work properly because of the 'default' section of this switch.
    switch (e.keyCode) {
      // Enter
      case 13:
        if (hoverIdx !== undefined) handleItemSelection(hoverIdx)
        break
      // Escape
      case 27:
        if (isOpen) {
          hoverIdx = undefined
          close()
        }
        break
      default:
        if (value.length > 0 && !isOpen) open()
        break
    }
  }

  function handleKeyDown (e) {
    switch (e.keyCode) {
      // Arrow up
      case 38:
        handleArrowUp()
        break
      // Arrow down
      case 40:
        handleArrowDown()
        break
      default:
        break
    }
  }

  function handleArrowUp () {
    if (hoverIdx === undefined) {
      hoverIdx = collection.length - 1
      return
    }

    if (hoverIdx === 0) hoverIdx = collection.length - 1
    else hoverIdx = hoverIdx - 1
  }

  function handleArrowDown () {
    if (hoverIdx === undefined) {
      hoverIdx = 0
      return
    }

    if (hoverIdx === collection.length - 1) hoverIdx = 0
    else hoverIdx = hoverIdx + 1
  }

  function handleBlur () {
    if (isOpen) close()
  }

  function handleInputClick () {
    if (!editable) toggle()
  }
  
  function handleResetClick () {
    if (isOpen) close()

    hoverIdx = undefined
    selectedItem = undefined
    value = ''
    icon = undefined
    editable = true
    resetable = false

    if (collection !== initialCollection) collection = initialCollection
  }

  function addOverflow () {
    listElem.classList.add('overflow-y-scroll')
    listElem.classList.remove('overflow-hidden')
  }

  function removeOverflow () {
    listElem.classList.remove('overflow-y-scroll')
    listElem.classList.add('overflow-hidden')
  }

  function handleWindowClick (e) {
    if (!inputContainerElem.contains(e.target) && isOpen) close()
  }
</script>

<svelte:options accessors={true} />

<div class="{className} relative">
  <div class="flex items-center py-0.5 px-2 bg-white border shadow-sm rounded-md focus-within:ring-2 ring-blue-400 text-gray-800" class:ring-2={isOpen} bind:this={inputContainerElem}>
    {#if editable}
      {#if icon}
        <span class="mr-1.5 icon icon-{icon}"></span>
      {/if}
      <input type="text" class="flex-grow text-sm outline-none" placeholder={placeholder} bind:value={value} on:keyup={handleKeyUp} on:keydown={handleKeyDown} on:blur={handleBlur} on:click={handleInputClick}>
    {:else}
      <div class="flex-grow text-sm cursor-pointer" on:click={handleInputClick}>
        {#if icon}
          <span class="inline-block w-5 icon icon-{icon}"></span>
        {/if}
        {value}
      </div>
    {/if}
    {#if resetable}
      <span class="pl-1 hover:text-red-500 icon icon-cancel cursor-pointer" on:click={handleResetClick}></span>
    {:else}
      <span class="pl-1 icon icon-down-open-mini cursor-pointer" on:click={toggle}></span>
    {/if}
  </div>

  {#if isOpen}
    <ul class="absolute z-10 w-full mt-1 p-1 bg-white border shadow rounded-md text-sm cursor-pointer overflow-hidden" bind:this={listElem} transition:reveal={{ duration: 150, vertical: true, opacity: true }} on:introstart={removeOverflow} on:outroend={addOverflow}>
      {#each collection as item, idx}
        <li class="py-1 px-2 rounded-md text-gray-800 whitespace-nowrap" class:bg-blue-50={idx === hoverIdx} on:click={() => handleItemSelection(idx)} on:mouseover={() => (hoverIdx = idx)}>
          {#if item.icon}
            <span class="inline-block w-5 icon icon-{item.icon}"></span>
          {/if}
          {item.value}
        </li>
      {/each}
    </ul>
  {/if}
</div>
