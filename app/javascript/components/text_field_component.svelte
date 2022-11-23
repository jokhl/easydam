<script>
  import { onMount, createEventDispatcher } from 'svelte'

  export let name
  export let value
  export let className
  export let isFocus = false
  export function focus () {
    inputElem.focus()
  }
  
  const dispatch = createEventDispatcher()
  let inputElem

  onMount(() => {
    if (isFocus) focus()
  })

  function handleKeyUp (e) {
    if (e.keyCode === 13) {
      dispatch('saveNewValue', { name: name, value: value })
    } else if (e.keyCode === 27) {
      dispatch('cancel')
    }
  }
</script>

<input type="text" name={name} class="{className}" on:keyup={handleKeyUp} bind:value={value} bind:this={inputElem}>
