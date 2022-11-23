<script>
  import { onMount, createEventDispatcher } from 'svelte'
  import {
    registerKeyBindings,
    deleteKeyBindings,
    redirectKeyBindTo
  } from '../../utilities'

  export let asset

  const dispatch = createEventDispatcher()
  export const keyBindingsID = 'lightbox'
  const keyBindings = [
    { // Enter
      keyCode: 13,
      callback: close
    },
    { // Escape
      keyCode: 27,
      callback: close
    },
    { // Space
      keyCode: 32,
      callback: close
    },
    { // Arrow left
      keyCode: 37,
      callback: (e) => redirectKeyBindTo(e, 'masonry')
    },
    { // Arrow up
      keyCode: 38,
      callback: (e) => redirectKeyBindTo(e, 'masonry')
    },
    { // Arrow right
      keyCode: 39,
      callback: (e) => redirectKeyBindTo(e, 'masonry')
    },
    { // Arrow down
      keyCode: 40,
      callback: (e) => redirectKeyBindTo(e, 'masonry')
    }
  ]

  onMount(() => {
    registerKeyBindings(keyBindingsID, keyBindings)
  })

  function close () {
    deleteKeyBindings(keyBindingsID)
    dispatch('closeWindow', { keyBindingsID: keyBindingsID })
  }
</script>

<img src="/uploads/{asset.file_data.derivatives.large.id}" class="w-full h-full object-contain" alt="{asset.name}">
