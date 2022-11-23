<script>
  import { onMount } from 'svelte'
  import { fly } from 'svelte/transition'
  import { DateTime } from 'luxon'
  import MessageBus from 'message-bus-client'
  import '../../lib/message_bus_ajax'
  import { openWindow } from '../../utilities'
  import { pageTitleStore } from '../../stores'

  import MasonryComponent from '../../components/masonry_component.svelte'
  import ImageComponent from '../../components/image_component.svelte'

  import FileInfoView from '../shared/file_info_view.svelte'
  import LightBoxView from '../shared/lightbox_view.svelte'

  export let id

  let importSession = { assets: [] }
  let progressMessage
  let progressWidth = 0
  let rectangles = []
  let isLightboxOpen = false
  let lighboxWindowComponent
  let selectedBrickIdx
  let brickHeight = 16 // unit: rem
  let galleryComponent

  //$: console.log(importSession)

  onMount(() => {
    if (id) {
      fetch(`/api/import_sessions/${id}`)
        .then(res => res.json())
        .then(data => {
          formatImportSession(data)
          $pageTitleStore = `Import #${importSession.id}`
        })

      MessageBus.start()
      MessageBus.callbackInterval = 1000 // every second
      MessageBus.subscribe(`/import_sessions/${id}`, onData, 0)
    } else {
      console.error('ERROR: No import session ID given!')
    }
  })

  function formatImportSession (data) {
    const newImportSession = data
    newImportSession.assets = newImportSession.assets.map(a => {
      return {
        ...a,
        width: a.file_data.metadata.width,
        height: a.file_data.metadata.height
      }
    })
    importSession = newImportSession
  }

  function onData (data) {
    const json = JSON.parse(data)
    if (json.event === 'progress') onProgress(json.payload)
  }

  function onProgress (data) {
    formatImportSession(data.import_session)
    progressMessage = data.message
    progressWidth = data.progress * 100
  }

  function getHumanDate (isoDate) {
    const dt = DateTime.fromISO(isoDate)
    return dt.toLocaleString(DateTime.DATE_FULL)
  }

  function handleInfoClick (e) {
    const assetIdx = e.target.dataset['idx']
    openFileInfoWindow(assetIdx)
  }

  function handleOpenFileInfoEvent (e) {
    openFileInfoWindow(e.detail.idx)
  }

  function openFileInfoWindow (assetIdx) {
    openWindow({
      title: 'Info',
      resizeable: false,
      width: '33%',
      height: 'auto',
      y: '15%',
      view: FileInfoView,
      props: {
        asset: importSession.assets[assetIdx]
      }
    })
  }

  // Open the lightbox view.
  function handleDoubleClick (e) {
    if (isLightboxOpen) {
      closeLightbox()
      return
    }

    const idx = e.detail.idx
    const asset = importSession.assets[idx]
    openLightbox(asset)
  }

  function openLightbox (asset) {
    lighboxWindowComponent = openWindow({
      header: false,
      resizeable: false,
      width: asset.file_data.derivatives.large.metadata.width,
      height: asset.file_data.derivatives.large.metadata.height,
      maxWidth: '90%',
      maxHeight: '90%',
      modal: true,
      className: 'bg-all-transparent',
      resizeOnMounted: true,
      view: LightBoxView,
      props: {
        asset: asset
      },
      containerClass: 'w-full h-full'
    })
    lighboxWindowComponent.$on('escape', handleEscapeKey)
    lighboxWindowComponent.$on('didClose', handleLightboxDidClose)
    isLightboxOpen = true
  }

  function handleLightboxDidClose () {
    isLightboxOpen = false
    lighboxWindowComponent = undefined
  }

  function closeLightbox () {
    lighboxWindowComponent.close()
  }

  function handleBrickChange (e) {
    const idx = e.detail.idx
    selectedBrickIdx = idx

    if (isLightboxOpen) {
      const asset = importSession.assets[idx]
      lighboxWindowComponent.$set({
        props: {
          asset: asset
        }
      })
      lighboxWindowComponent.resize(
        asset.file_data.derivatives.large.metadata.width,
        asset.file_data.derivatives.large.metadata.height
      )
    }
  }

  function handleDeselectBrick () {
    selectedBrickIdx = undefined
  }

  function handleEscapeKey () {
    if (isLightboxOpen) {
      closeLightbox()
    }
  }

  function handleImageLoaded (e, idx) {
    galleryComponent.showBrick(idx)
  }
</script>

{#if importSession}
  <div class="sticky top-0 z-10 w-full py-3 bg-theme-light-gray border-b border-gray-300 shadow-sm">
    <h1 class="px-4 text-2xl font-bold">Import #{importSession.id}</h1>

    {#if importSession.status === 'processing'}
      <span class="block w-full mt-4 px-4 text-sm text-gray-500">{progressMessage}</span>
      <span class="block w-full h-3 mt-2 px-4 rounded-full overflow-hidden">
        <span class="block h-full bg-blue-600 transition-all duration-150" style="width: {progressWidth}%;"></span>
      </span>
    {:else}
      <div class="flex flex-wrap w-full mt-3 pt-3 px-4 border-t border-gray-300 border-inset-t-gray text-sm">
        <div class="w-1/12">
          <span class="block text-gray-400 font-medium">Date</span>
          <span class="block text-gray-900">{getHumanDate(importSession.created_at)}</span>
        </div>
        <div class="w-1/12 pl-4 border-l border-gray-300 border-inset-l-gray">
          <span class="block text-gray-400 font-medium">Assets</span>
          <span class="block text-gray-900">{importSession.assets_count}</span>
        </div>
        <div class="w-1/12 pl-4 border-l border-gray-300 border-inset-l-gray">
          <span class="block text-gray-400 font-medium">Status</span>
          <span class="block text-gray-900">
            {#if importSession.status === 'error'}
              ❌
            {:else if importSession.status === 'partial'}
              ⚠️
            {:else}
              ✅
            {/if}
            {importSession.status}
          </span>
        </div>
        <div class="w-9/12 pl-4 border-l border-gray-300 border-inset-l-gray">
          <span class="block text-gray-400 font-medium">Remark</span>
          <span class="block text-gray-900">{importSession.remark || '-'}</span>
        </div>
      </div>
    {/if}
  </div>

  <MasonryComponent className="w-full h-screen pt-2" bricks={importSession.assets} rectangles={rectangles} brickHeight={brickHeight} keyboardNavigation={true} let:brick={asset} let:idx={idx} on:doubleClick={handleDoubleClick} on:deselectBrick={handleDeselectBrick} on:brickSelectionChange={handleBrickChange} on:openFileInfo={handleOpenFileInfoEvent} bind:this={galleryComponent}>

    {#if asset.file_data.derivatives && asset.file_data.derivatives.small}
      <figure class="relative w-full h-full border-4 border-transparent rounded-md group box-border" data-idx="{idx}">
        
        <ImageComponent src="/uploads/{asset.file_data.derivatives.small.id}" className="w-full h-full object-cover" alt="{asset.name}" transitionFunction={fly} transitionParams={{ x: -50, duration: 300 }} preventBrowserDragging={true} on:imageLoaded={(e) => handleImageLoaded(e, idx)} />
    
        <figcaption class="w-full mt-1 text-center">
          <span class="inline-block max-w-full mt-1 py-0.5 px-1 rounded-md text-sm truncate">{asset.file_data.metadata.filename}</span>
        </figcaption>
        
      </figure>
    {/if}
  
  </MasonryComponent>
{/if}
