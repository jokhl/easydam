<script>
  import { createEventDispatcher } from 'svelte'

  export let name
  export let editable = false
  export let textareaClass
  export let textClass
  export let value
  export let mode = 'view'

  const dispatch = createEventDispatcher()
  let initialValue = value

  function handleSaveClick () {
    dispatch('saveNewValue', { name: name, value: value })
    initialValue = value
    mode = 'view'
  }

  function handleCancelClick () {
    value = initialValue
    mode = 'view'
  }

  function handleEditClick () {
    mode = 'edit'
  }
</script>

{#if editable === true && mode === 'edit'}
  <div class="flex flex-col">
    <textarea class="flex-grow {textareaClass}" bind:value={value}></textarea>
    <div class="w-full my-1 text-right">
      <button class="icon icon-check text-gray-800 hover:text-green-600" on:click={handleSaveClick}></button>
      <button class="ml-1 icon icon-cancel text-gray-800 hover:text-red-600" on:click={handleCancelClick}></button>
    </div>
  </div>
{:else}
  <p class="group {textClass}">
    {value || ''}
    <button class="group-hover:inline-block text-gray-400 hover:text-gray-800 cursor-pointer icon icon-pencil" class:hidden={value} on:click={handleEditClick}></button>
  </p>
{/if}
