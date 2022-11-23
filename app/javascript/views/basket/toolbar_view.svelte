<script>
  import { onMount } from 'svelte'
  import { basketStore } from '../../stores'
  import { formatBytes } from '../../utilities'

  let basketItems = []

  basketStore.subscribe(items => {
    basketItems = items
  })

  onMount(() => {
    fetch('/api/basket?full=true')
      .then(res => res.json())
      .then(data => basketStore.set(data))
  })

  function handleClearClick () {
    fetch('/api/basket/clear')
      .then(res => {
        if (res.ok) basketStore.set([])
        else console.error('ERROR', res)
      })
  }
</script>

<header class="flex items-center h-8 toolbar toolbar-header">
  <div class="w-1/3 px-2">
    <button class="text-gray-500 hover:text-gray-600" on:click={handleClearClick}>
      <span class="icon icon-back"></span> <span class="text-sm">Clear</span>
    </button>
  </div>
  <div class="w-1/3 text-gray-600 text-center text-sm">Basket</div>
  <div class="w-1/3 px-2 text-right">
    <a href="/api/basket/download" target="_blank" class="text-gray-500 hover:text-gray-600">
      <span class="icon icon-download"></span>
    </a>
  </div>
</header>

<div class="max-h-96 overflow-y-scroll overflow-x-hidden py-1 px-2">
  {#if basketItems.length > 0}
    <ul class="w-full">
      {#each basketItems as item}
        <li class="flex items-center w-full py-1 px-2 border-b">
          <img src="/uploads/{item.file_data.derivatives.small.id}" class="w-16 h-16 object-cover" alt="{item.file_data.metadata.filename}">
          <div class="flex-grow pl-4">
            <span class="block text-sm text-gray-700">{item.file_data.metadata.filename}</span>
            <span class="text-xs text-gray-400">{formatBytes(item.file_data.metadata.size)}</span>
          </div>
        </li>
      {/each}
    </ul>
  {:else}
    <p class="text-sm text-gray-400">Your basket is empty.</p>
  {/if}
</div>
