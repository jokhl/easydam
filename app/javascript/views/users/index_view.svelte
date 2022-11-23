<script>
  import { onMount, onDestroy } from 'svelte'
  import { DateTime } from 'luxon'
  import page from 'page'

  import AdminController from '../../controllers/admin_controller'

  let tableElem, selectedRowIdx, selectedRowElem
  let users = []

  onMount(() => {
    window.addEventListener('click', handleWindowClick)

    AdminController.getUsers()
      .then(data => (users = data))
  })

  onDestroy(() => {
    window.removeEventListener('click', handleWindowClick)
  })

  // Manually route to the show action when user double clicks on a row.
  function handleDoubleClick (userID) {
    page(`/admin/users/${userID}`)
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

  function getHumanDate (isoDate) {
    const dt = DateTime.fromISO(isoDate)
    return dt.toLocaleString(DateTime.DATETIME_FULL)
  }
</script>

<div class="flex items-center justify-between w-full p-4">
  <h1 class="text-2xl font-bold">
    Users
  </h1>
  <a href="/admin/users/new" class="btn btn-default">
    <span class="inline-block mr-1 icon icon-user-add"></span> New
  </a>
</div>

<div class="mt-3 px-4">
  <table class="w-full border table-striped select-none" bind:this={tableElem}>
    <thead>
      <tr>
        <th class="w-2/12">Name</th>
        <th class="w-1/12">Login</th>
        <th>Active</th>
        <th class="w-9/12">Last Login</th>
      </tr>
    </thead>
    <tbody>
      {#if users.length == 0}
        <tr>
          <td class="py-2 text-gray-400 text-xs italic" colspan="2">There are no users yet.</td>
        </tr>
      {:else}
        {#each users as user, idx}
          <tr class:active={selectedRowIdx === idx} on:click={(e) => handleRowClick(e, idx)} on:dblclick={() => handleDoubleClick(user.id)}>
            <td>{user.name}</td>
            <td>{user.login}</td>
            <td>
              {#if user.active}
                ✅
              {:else}
                ❌
              {/if}
            </td>
            <td>{user.last_login_at ? getHumanDate(user.last_login_at) : '-'}</td>
          </tr>
        {/each}
      {/if}
    </tbody>
  </table>
</div>
