<script>
  import { onMount } from 'svelte'

  import TagsController from '../../controllers/tags_controller'

  import SpinnerComponent from '../../components/spinner_component.svelte'

  export let assetID

  let tagContexts = []
  let selectedTagContextIdx
  let tags = []
  let isLoading = false

  onMount(() => {
    TagsController
      .getTagContexts()
      .then(data => (tagContexts = data))
  })

  function handleTagContextSelection (e) {
    const idx = parseInt(e.target.dataset.idx)
    
    // If the user clicked on the same item, we assume she means to unselect it.
    if (selectedTagContextIdx === idx) {
      selectedTagContextIdx = undefined
      return
    }

    selectedTagContextIdx = idx
    isLoading = true
    TagsController
      .getTagContext(tagContexts[idx].id)
      .then(data => {
        tags = data.all_tags
        isLoading = false
      })
  }
</script>

<div class="flex flex-col w-full h-full py-2 bg-theme-light-gray box-border">
  <div class="py-2 px-4">Tags</div>

  <div class="flex-grow flex items-center w-full -mx-2 py-2 pl-4 pr-2">
    <ul class="w-1/3 h-full mx-2 bg-white border overflow-y-scroll overflow-ellipsis select-none">
      {#each tagContexts as tagContext, idx}
        <li class="py-0.5 px-2" class:bg-blue-500={idx === selectedTagContextIdx} class:text-white={idx === selectedTagContextIdx} data-idx="{idx}" on:click={handleTagContextSelection}>
          {tagContext.label}
        </li>
      {/each}
    </ul>
    <ul class="w-2/3 h-full ml-2 bg-white border text-sm overflow-y-scroll overflow-ellipsis select-none">
      {#if selectedTagContextIdx === undefined}
        <li class="py-0.5 px-2 italic text-gray-500">
          Please select a tag context.
        </li>
      {:else if isLoading}
        <li class="py-0.5 px-2">
          <SpinnerComponent />
        </li>
      {:else}
        {#each tags as tag}
          <li class="py-0.5 px-2">
            {tag.value}
          </li>
        {/each}
      {/if}
    </ul>
  </div>
</div>
