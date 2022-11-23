<script>
  import { onMount, onDestroy } from 'svelte'
  import { openWindow } from '../../utilities'
  import { pageTitleStore } from '../../stores'

  import PropertiesController from '../../controllers/properties_controller'

  import ButtonComponent from '../../components/button_component.svelte'

  import NewPropertyView from './new_view.svelte'

  let tableElem, selectedRowIdx, selectedRowElem
  let properties = []

  onMount(() => {
    $pageTitleStore = 'Properties'
    window.addEventListener('click', handleWindowClick)

    PropertiesController.getProperties()
      .then(data => (properties = data))

    mountPageActions()
  })

  onDestroy(() => {
    window.removeEventListener('click', handleWindowClick)
    unmountPageActions()
  })

  // Manually route to the show action when user double clicks on a row.
  function handleDoubleClick (roleID) {
    page(`/admin/roles/${roleID}`)
  }

  function handleRowClick(e, idx) {
    selectedRowIdx = idx
    selectedRowElem = e.target
  }

  // This function handles mouse clicks outside the table.
  function handleWindowClick (e) {
    if (!tableElem.contains(e.target)) {
      selectedRowIdx = undefined
      selectedRowElem = undefined
    }
  }

  function mountPageActions () {
    const navElem = document.querySelector('#nav_page_actions')
    const pageActionComponent = new ButtonComponent({
      target: navElem,
      props: {
        className: 'mx-2 btn btn-default',
        icon: 'plus',
        label: 'New Property',
        onClick: openNewPropertyDialog
      }
    })
  }

  function unmountPageActions () {
    const navElem = document.querySelector('#nav_page_actions')
    navElem.innerHTML = ''
  }

  function openNewPropertyDialog () {
    openWindow({
      title: 'New Property',
      resizeable: false,
      width: '25%',
      height: 'auto',
      y: '25%',
      className: 'rounded-lg',
      view: NewPropertyView,
      containerClass: 'min-h-full bg-theme-light-gray',
      props: {
        onSearchDone: took => {
          searchSpeedElem.textContent = `${took} ms`
        }
      }
    })
  }
</script>

<table class="w-full table-striped select-none" bind:this={tableElem}>
  <thead>
    <tr>
      <th class="w-2/12">Property Name</th>
      <th>Type</th>
    </tr>
  </thead>
  <tbody>
    {#if properties.length == 0}
      <tr>
        <td class="py-2 text-gray-400 text-xs italic" colspan="2">There are no properties defined yet.</td>
      </tr>
    {:else}
      {#each properties as property, idx}
        <tr class:active={selectedRowIdx === idx} on:click={(e) => handleRowClick(e, idx)} on:dblclick={() => handleDoubleClick(role.id)}>
          <td>{property.name}</td>
          <td>{property.prop_type || ''}</td>
        </tr>
      {/each}
    {/if}
  </tbody>
</table>
