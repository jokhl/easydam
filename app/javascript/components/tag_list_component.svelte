<script>
  import { onMount, onDestroy } from 'svelte'
  import { tagContextsStore } from '../stores'

  import TagsController from '../controllers/tags_controller'

  export let assetID

  let tagContexts = []
  let tags = []
  let unsubscribe
  let tagListElem

  onMount(() => {
    TagsController.getAssetTags(assetID)
      .then(data => (tags = data))

    TagsController.getTagContexts()
      .then(data => ($tagContextsStore = data))

    unsubscribe = tagContextsStore.subscribe(newTagContexts => {
      tagContexts = newTagContexts
    })
  })

  onDestroy(() => {
    unsubscribe()
  })

  function handleSave (e) {
    const newTag = e.detail
    const previousTagIdx = tags.findIndex(tag => tag.context === newTag.context)
    
    if (previousTagIdx >= 0) {
      tags[previousTagIdx] = newTag
      tags = tags // manually trigger a refresh from Svelte
    } else {
      tags = [...tags, newTag]
    }
  }

  function onAddPropertyClick () {
    //const newComponent = new DynamicTagFieldComponent({
    //  target: tagListElem,
    //  props: {
    //    editable: true,
    //    tagContexts: tagContexts,
    //    assetID: assetID,
    //    mode: 'edit'
    //  }
    //})
    //newComponent.$on('saveNewValue', handleSave)
    //newComponent.$on('destroy', handleDestroy)
  }

  function handleDestroy (e) {
    this.$destroy()
  }
</script>

<button class="py-0.5 px-1 bg-gray-200 rounded-md text-xs text-gray-700 font-medium" on:click={onAddPropertyClick}>
  Add property
</button>

<div class="w-full" bind:this={tagListElem}>
  {#each tags as tag}
    <div class="my-1 group">
      <span class="text-gray-700 font-semibold">
        {tagContextLabel}
      </span>
      <span class="{textClass} text-gray-500">
        {#each tag.values as tagValue}
          <span class="mx-0.5 py-0.5 px-1 bg-blue-100 rounded-md text-xs text-blue-800">{tagValue}</span>
        {/each}
        <button class="group-hover:inline-block text-gray-400 hover:text-gray-800 cursor-pointer icon icon-pencil" on:click={handleEditClick}></button>
      </span>
    </div>
  {/each}
</div>
