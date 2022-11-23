<script>
  import { onMount, onDestroy } from 'svelte'
  import { notify, openWindow, updatePagination } from '../../utilities'
  import { get } from 'svelte/store'
  import { basketStore, visibleAssetsStore, pageTitleStore } from '../../stores'

  import AssetsController from '../../controllers/assets_controller'

  import MasonryComponent from '../../components/masonry_component.svelte'
  import OffcanvasComponent from '../../components/offcanvas_component.svelte'
  import ButtonComponent from '../../components/button_component.svelte'
  import ImageComponent from '../../components/image_component.svelte'
  import ContextMenuComponent from '../../components/context_menu_component.svelte'

  import LightBoxView from '../shared/lightbox_view.svelte'
  import FileInfoView from '../shared/file_info_view.svelte'
  import FiltersView from '../shared/filters_view.svelte'
  import TagsView from '../shared/tags_view.svelte'

  let assets = []
  let rectangles = []
  let isLightboxOpen = false
  let lighboxWindowComponent
  let selectedBricksIdxes = []
  let unsubscribe
  let pageNumber = 1
  let paginationComponent
  let filtersComponent
  let pageActionComponent
  let brickHeight = 16 // unit: rem
  let galleryComponent

  $: rcMenu = buildMenu(selectedBricksIdxes)

  onMount(() => {
    $pageTitleStore = 'All Assets'
    unsubscribe = visibleAssetsStore.subscribe(newAssets => {
      assets = newAssets.map(a => {
        return {
          ...a,
          width: a.file_data.metadata.width,
          height: a.file_data.metadata.height
        }
      })
    })

    AssetsController.getAssets(pageNumber)
      .then(data => {
        $visibleAssetsStore = data.assets
        paginationComponent = updatePagination(data.pagination)
        paginationComponent.$set({ onPageChange: handlePageChange })
      })

    mountPageActions()
  })

  onDestroy(() => {
    unsubscribe()
    pageActionComponent.$destroy()
  })

  function mountPageActions () {
    const navElem = document.querySelector('#nav_page_actions')
    pageActionComponent = new ButtonComponent({
      target: navElem,
      props: {
        className: 'mx-2 btn btn-default',
        icon: 'list',
        label: 'Filters',
        onClick:  handleFiltersClick
      }
    })
  }

  function handleFiltersClick () {
    filtersComponent.toggle()
  }

  function handlePageChange (pageNumber) {
    AssetsController.getAssets(pageNumber)
      .then(data => {
        $visibleAssetsStore = data.assets
        paginationComponent.$set({ data: data.pagination })
      })
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
        asset: assets[assetIdx]
      }
    })
  }

  function handleBasketClick (e) {
    const assetIdx = e.target.dataset['idx']
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content
    const asset = assets[assetIdx]
    fetch('/api/basket/add', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        authenticity_token: csrfToken,
        asset_id: asset.id
      })
    }).then(res => {
      if (res.ok) {
        basketStore.set([...get(basketStore), asset])
        notify({
          duration: 5000,
          props: {
            title: asset.file_data.metadata.filename,
            subtitle: `The asset was added to the basket.`,
            status: 'success'
          }
        })
      } else {
        console.error('ERROR')
        console.error(res)
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
    const asset = assets[idx]
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
    const idxes = e.detail.bricks
    selectedBricksIdxes = idxes

    if (isLightboxOpen) {
      const asset = assets[selectedBricksIdxes[0]]
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
    selectedBricksIdxes = undefined
  }

  function handleEscapeKey () {
    if (isLightboxOpen) {
      closeLightbox()
    }
  }

  function handleImageLoaded (e, idx) {
    galleryComponent.showBrick(idx)
  }

  function handleTagClick (e) {
    const assetIdx = e.target.dataset['idx']

    openWindow({
      title: 'Tags',
      resizeable: false,
      width: '33%',
      y: '15%',
      view: TagsView,
      containerClass: 'h-full',
      props: {
        assetID: assets[assetIdx].id
      }
    })
  }

  function buildMenu (idxes) {
    const rcMenu = []

    if (idxes && idxes.length > 0) {
      rcMenu.push({ title: 'Add property' })
      
      if (idxes.length === 1) {
        rcMenu.push({
          title: `Add 1 item to basket`,
          callback: onMenuClickAddToBasket
        })
      } else {
        rcMenu.push({
          title: `Add ${idxes.length} items to basket`,
          callback: onMenuClickAddToBasket
        })
      }
    }

    return rcMenu
  }

  function onMenuClickAddToBasket () {

  }
</script>

<OffcanvasComponent view={FiltersView} bind:this={filtersComponent} />

<ContextMenuComponent menu={rcMenu} />

<MasonryComponent className="w-full h-screen pt-2" bricks={assets} rectangles={rectangles} brickHeight={brickHeight} keyboardNavigation={true} let:brick={asset} let:idx={idx} on:doubleClick={handleDoubleClick} on:deselectBrick={handleDeselectBrick} on:brickSelectionChange={handleBrickChange} on:openFileInfo={handleOpenFileInfoEvent} bind:this={galleryComponent}>

  <figure class="relative w-full h-full border-4 border-transparent rounded-md group box-border" data-idx="{idx}">

    <div class="absolute top-2 right-2 flex items-center py-1 px-2 bg-black rounded transition-all duration-200 opacity-0 group-hover:opacity-75">
      <button class="mx-1 icon icon-info-circled text-white" data-idx={idx} on:click={handleInfoClick}></button>
      <button class="mx-1 icon icon-tag text-white" data-idx={idx} on:click={handleTagClick}></button>
      <button class="mx-1 icon icon-down text-white" data-idx={idx} on:click={() => {}}></button>
      <button class="mx-1 icon icon-basket text-white" data-idx={idx} on:click={handleBasketClick}></button>
    </div>

    <ImageComponent src="/uploads/{asset.file_data.derivatives.small.id}" className="w-full h-full object-cover" alt="{asset.name}" preventBrowserDragging={true} on:imageLoaded={(e) => handleImageLoaded(e, idx)} />

    <figcaption class="w-full mt-1 text-center">
      <span class="inline-block max-w-full mt-1 py-0.5 px-1 rounded-md text-sm truncate">{asset.file_data.metadata.filename}</span>
    </figcaption>
    
  </figure>

</MasonryComponent>
