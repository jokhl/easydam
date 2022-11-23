<script>
  import { onMount, onDestroy } from 'svelte'

  import AdminController from '../../controllers/admin_controller'

  let tableElem, selectedRowIdx, selectedRowElem
  let roles = []

  onMount(() => {
    window.addEventListener('click', handleWindowClick)

    AdminController.getRoles()
      .then(data => (roles = data))
  })

  onDestroy(() => {
    window.removeEventListener('click', handleWindowClick)
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
</script>

<div class="flex items-center justify-between w-full p-4">
  <h1 class="text-2xl font-bold">
    Roles
  </h1>
  <a href="/admin/roles/new" class="btn btn-default">
    <span class="inline-block mr-1 icon icon-user-add"></span> New
  </a>
</div>

<div class="mt-3 px-4">
  <table class="w-full border table-striped select-none" bind:this={tableElem}>
    <thead>
      <tr>
        <th class="w-2/12">Role Name</th>
        <th>Description</th>
      </tr>
    </thead>
    <tbody>
      {#if roles.length == 0}
        <tr>
          <td class="py-2 text-gray-400 text-xs italic" colspan="2">There are no roles defined yet.</td>
        </tr>
      {:else}
        {#each roles as role, idx}
          <tr class:active={selectedRowIdx === idx} on:click={(e) => handleRowClick(e, idx)} on:dblclick={() => handleDoubleClick(role.id)}>
            <td>{role.name}</td>
            <td>{role.description || ''}</td>
          </tr>
        {/each}
      {/if}
    </tbody>
  </table>
</div>
