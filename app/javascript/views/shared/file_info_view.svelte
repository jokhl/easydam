<script>
  import { onMount } from 'svelte'
  import { DateTime } from 'luxon'
  import { formatBytes } from '../../utilities'

  // Components
  import AccordionComponent from '../../components/accordion_component.svelte'
  import DynamicTextareaComponent from '../../components/dynamic_textarea_component.svelte'
  import TagListComponent from '../../components/tag_list_component.svelte'

  export let asset
  let metadata = {}, filename, extension, thumbnailElem

  onMount(() => {
    // Separate the 'all' key from the metadata
    metadata = Object.assign({}, asset.file_data.metadata)
    // delete metadata.all

    filename = metadata.filename.replace(/\.[^/.]+$/, "")
    extension = /^.+\.([^.]+)$/.exec(metadata.filename)[1] || ''
  })

  function getHumanDate (isoDate) {
    const dt = DateTime.fromISO(isoDate)
    return dt.setLocale('fr').toLocaleString(DateTime.DATETIME_MED)
  }

  function handleUpdate (e) {
    asset[e.detail.name] = e.detail.value
  }
</script>

<div class="flex items-center border-b font-semibold text-gray-800">
  <span class="flex-grow py-3 px-4 border-r">{filename}</span>
  <div class="py-3 px-4">
    <span class="py-1 px-2 bg-blue-500 rounded-md text-white text-sm uppercase">{extension}</span>
  </div>
</div>

<div class="flex items-center border-b text-gray-700">

  <div class="flex-grow flex py-3 border-r">
    <figure class="flex items-center justify-center max-w-24 max-h-24 mx-4" bind:this={thumbnailElem}>
      <img src="/uploads/{asset.file_data.derivatives.small.id}" class="max-w-full max-h-full object-contain rounded-md" alt="{metadata.filename}">
    </figure>
    <div>
      <span class="block text-gray-400 text-sm">Content-Type</span>
      <span class="block text-gray-600">
        {metadata.mime_type}
      </span>
      <span class="block text-gray-400 text-sm">Resolution</span>
      <span class="block text-gray-600">
        {#if metadata.width && metadata.height}
          {metadata.width} x {metadata.height} px
        {:else}
          N/A
        {/if}
      </span>
    </div>
  </div>
  
  <span class="flex-grow py-4 px-6 text-xl text-gray-800 text-center">
    {formatBytes(metadata.size, 0)}
  </span>
</div>

<div class="flex items-center bg-theme-light-gray border-b text-sm">
  <div class="w-1/2 py-3 px-4 border-r">
    <span class="block pb-1 text-gray-400">Created On</span>
    <span class="block text-gray-600 truncate">
      {getHumanDate(asset.created_at)}
    </span>
  </div>
  <div class="w-1/2 py-3 px-4">
    <span class="block pb-1 text-gray-400">Last Modified On</span>
    <span class="block text-gray-600 truncate">
      {getHumanDate(asset.updated_at)}
    </span>
  </div>
</div>

<div class="py-1 px-4 bg-theme-light-gray border-b text-sm">
  <AccordionComponent icon="right-dir" label="Description" maxHeight="max-h-auto" isOpen={true} on:childResize>
    <DynamicTextareaComponent name="description" textareaClass="w-full py-1 px-2 bg-white border text-sm outline-none" textClass="pb-1 px-4 text-xs text-gray-700" content={asset.description} editable={true} on:saveNewValue={handleUpdate} />
  </AccordionComponent>
</div>

<div class="py-1 px-4 bg-theme-light-gray border-b text-sm">
  <AccordionComponent icon="right-dir" label="Tags" maxHeight="max-h-auto" isOpen={true} className="px-4" on:childResize>
    <TagListComponent assetID={asset.id} />
  </AccordionComponent>
</div>

<div class="py-1 px-4 bg-theme-light-gray border-b text-sm">
  <AccordionComponent icon="right-dir" label="More Info" maxHeight="max-h-24" on:childResize>
    <ul class="w-full pb-1 px-4 text-xs">
      <li>
        <span class="text-gray-400">Asset ID</span>
        <span class="ml-2 text-gray-700">{asset.id}</span>
      </li>
      {#each Object.keys(metadata) as key}
        <li>
          <span class="text-gray-400">{key}</span>
          <span class="ml-2 text-gray-700">{metadata[key]}</span>
        </li>
      {/each}
    </ul>
  </AccordionComponent>
</div>

<div class="py-1 px-4 bg-theme-light-gray border-b text-sm">
  <AccordionComponent icon="right-dir" label="Sharing & Permissions" maxHeight="max-h-auto" on:childResize>
  </AccordionComponent>
</div>
