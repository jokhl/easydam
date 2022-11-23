<script>
  import { onMount, onDestroy } from 'svelte'
  import page from 'page'
  import {
    notify,
    openWindow,
    handleKeyDown
  } from './utilities'

  // Views
  import BasketToolbarView from './views/basket/toolbar_view.svelte'
  import NotificationCenterView from './views/shared/notification_center_view.svelte'
  import SearchDialogView from './views/shared/search_dialog_view.svelte'

  // Components
  import Router from './router.svelte'
  import Route from './route.svelte'
  import LinkComponent from './components/link_component.svelte'
  import ToolbarMenuComponent from './components/toolbar_menu_component.svelte'
  import RingProgressComponent from './components/ring_progress_component.svelte'

  // Controllers
  import AssetsController from './controllers/assets_controller'
  import ImportSessionsController from './controllers/import_sessions_controller'
  import AdminController from './controllers/admin_controller'
  import PropertiesController from './controllers/properties_controller'

  // Stores
  import { pageTitleStore } from './stores'

  const controllers = [
    AssetsController,
    ImportSessionsController,
    AdminController,
    PropertiesController
  ]

  // Each component pushes its key bindings on this stack. When the user uses
  // one of the shortcuts, we will fetch the tail of the stack and look for the
  // shortcut there and call its callback function. This way we can have the
  // same key bindings used according to which component is in focus.
  window.keyBindings = []
  window.globalKeyBindings = [
    {
      meta: true,
      keyCode: 75,
      callback: handleOpenSearchDialog
    }
  ]

  let uploadInputElem, routerComponent
  let sidebarOpen = true
  let basketOpen = false
  let uploading = false
  let uploadRingComponent
  let searchSpeedElem

  onMount(() => {
    document.addEventListener('keydown', handleKeyDown)
  })

  onDestroy(() => {
    document.removeEventListener('keydown', handleKeyDown)
  })

  function handleUploadSelection (e) {
    uploading = true
    const files = e.target.files

    // We use XMLHttpRequest because 'fetch' does not provide upload progress
    // tracking.
    const xhr = new XMLHttpRequest()

    xhr.upload.onprogress = function (event) {
      if (uploadRingComponent) {
        uploadRingComponent.setProgress(event.loaded / event.total)
      }
    }

    // Called if successful or not
    xhr.onloadend = function () {
      if (xhr.status == 200) {
        const str = files.length > 1 ? `${files.length} assets` : `${files[0].name}`
        const importSession = JSON.parse(xhr.response)

        if (importSession.status === 'partial') {
          notify({
            duration: 5000,
            props: {
              title: 'Upload partially successful',
              subtitle: `Only **${str}** uploaded.`,
              status: 'warning'
            }
          })
        } else {
          notify({
            duration: 5000,
            props: {
              title: 'Upload successful',
              subtitle: `**${str}** uploaded.`,
              status: 'success'
            }
          })
        }

        page(`/import_sessions/${importSession.id}`)
      } else {
        notify({
          duration: 5000,
          props: {
            title: 'Error',
            subtitle: 'Failed to upload assets.',
            status: 'error'
          }
        })
      }

      // Reset progress tracking variables
      uploading = false
      uploadRingComponent = undefined
    }

    // Prepare form data
    const formData = new FormData()
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content
    formData.append('authenticity_token', csrfToken)
    for (let i = 0; i < files.length; i++) {
      formData.append(e.target.name, files[i])
    }

    xhr.open('POST', '/api/import_sessions')
    xhr.send(formData)
  }

  function handleOpenSearchDialog (e) {
    e.preventDefault()
    openSearchDialog()
  }

  function openSearchDialog () {
    openWindow({
      header: false,
      resizeable: false,
      width: '50%',
      height: 'auto',
      y: '25%',
      className: 'rounded-lg',
      view: SearchDialogView,
      props: {
        onSearchDone: took => {
          searchSpeedElem.textContent = `${took} ms`
        }
      }
    })
  }
</script>

<div class="window overflow-hidden">

  <header class="toolbar toolbar-header select-none-all">
    <div class="flex items-center">
      <div class="w-1/4 flex items-center toolbar-actions">
        <div class="btn-group">
          <LinkComponent href="/" className="btn btn-default">
            <span class="icon icon-home"></span>
          </LinkComponent>
          <button class="btn btn-default">
            <span class="icon icon-star"></span>
          </button>
        </div>

        <button class="btn btn-default" on:click={() => (sidebarOpen = !sidebarOpen)}>
          <span class="icon icon-menu"></span>
        </button>

        <div class="flex items-center ml-1 input-text focus-within:ring-2 ring-blue-500">
          <span class="text-sm text-gray-700 icon icon-search"></span>
          <input type="text" class="pl-2 text-sm text-gray-800 outline-none" placeholder="Search">
        </div>
      </div>

      <div class="w-1/2 text-center text-sm title-inset">
        {$pageTitleStore}
      </div>

      <div class="flex items-center justify-end w-1/4">
        <div id="nav_page_actions">
        </div>
    
        <div>
          {#if uploading}
            <button class="btn btn-default" on:click={() => uploadInputElem.click()}>
              <RingProgressComponent bind:this={uploadRingComponent} /> Uploading...
            </button>
          {:else}
            <input type="file" name="import_session[assets_attributes][][file]" class="hidden" multiple bind:this={uploadInputElem} on:change={handleUploadSelection}>
            <button class="btn btn-default" on:click={() => uploadInputElem.click()}>
              <span class="icon icon-upload icon-text"></span>
              Upload
            </button>
          {/if}
        </div>
    
        <div class="relative mx-2">
          <button class="btn btn-default btn-dropdown" class:active={basketOpen} on:click={() => (basketOpen = !basketOpen)}>
            <span class="icon icon-basket"></span>
          </button>
          <ToolbarMenuComponent view={BasketToolbarView} className="right-0 w-80" isOpen={basketOpen} />
        </div>
      </div>
    </div>
  </header>

  <div class="window-content">
    <div class="pane-group">

      <div class="w-2/12 max-w-lg sidebar transition-all duration-500 overflow-hidden select-none-all" class:max-w-lg={sidebarOpen} class:max-w-0={!sidebarOpen}>
        <nav class="nav-group">
          <h5 class="nav-group-title">Shortcuts</h5>
          <LinkComponent href="/import_sessions" className="nav-group-item">
            <span class="icon icon-download"></span>
            Imports
          </LinkComponent>
        </nav>

        <nav class="nav-group">
          <h5 class="nav-group-title">Collections</h5>
        </nav>

        <nav class="nav-group">
          <h5 class="nav-group-title">Administration</h5>
          <LinkComponent href="/admin/users" className="nav-group-item">
            <span class="icon icon-users"></span>
            Users
          </LinkComponent>
          <LinkComponent href="/admin/roles" className="nav-group-item">
            <span class="icon icon-user"></span>
            Roles
          </LinkComponent>
          <LinkComponent href="/admin/properties" className="nav-group-item">
            <span class="icon icon-newspaper"></span>
            Properties
          </LinkComponent>
        </nav>
      </div>

      <div class="relative pane">
        <Router bind:this={routerComponent}>
          {#each controllers as controller}
            {#each controller.routes as route}
              <Route {...route} />
            {/each}
          {/each}
        </Router>
      </div>
    </div>
  </div>
  <footer class="flex items-center py-2 toolbar toolbar-footer">
    <div class="flex items-center w-1/3 px-4 text-xs">
      <span bind:this={searchSpeedElem}></span>
      <span class="ml-2" id="pagination_stats"></span>
    </div>
    <div id="pagination_nav" class="w-1/3 text-xs text-center">
    </div>
    <div class="w-1/3">
    </div>
  </footer>

  <NotificationCenterView />
</div>
