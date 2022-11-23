<script>
  import { onMount, onDestroy } from 'svelte'
  import page from 'page'
  import { DateTime } from 'luxon'
  import { openWindow } from '../../utilities'
  import { pageTitleStore } from '../../stores'

  import ImportSessionDetailsView from './details_view.svelte'

  let importSessions, selectedRowIdx, selectedRowElem, tableElem

  onMount(() => {
    $pageTitleStore = 'Imports'
    window.addEventListener('click', handleWindowClick)

    fetch(`/api/import_sessions`)
      .then(res => res.json())
      .then(data => (importSessions = data))
  })

  onDestroy(() => {
    window.removeEventListener('click', handleWindowClick)
  })

  // Manually route to the show action when user double clicks on a session.
  function handleDoubleClick (sessionID) {
    page(`/import_sessions/${sessionID}`)
  }

  function getHumanDate (isoDate) {
    const dt = DateTime.fromISO(isoDate)
    return dt.toLocaleString(DateTime.DATETIME_FULL)
  }

  function handleDetailsClick (importSession) {
    openWindow({
      title: 'Import Session Details',
      resizeable: false,
      width: '25%',
      height: 'auto',
      y: '15%',
      view: ImportSessionDetailsView,
      props: {
        importSession: importSession
      }
    })
  }

  function handleRowClick(e, idx) {
    selectedRowIdx = idx
    selectedRowElem = e.target
  }

  // This function handles mouse clicks outside the import sessions table.
  function handleWindowClick (e) {
    if (!tableElem.contains(e.target)) {
      selectedRowIdx = undefined
      selectedRowElem = undefined
    }
  }
</script>

<table class="w-full table-striped select-none" bind:this={tableElem}>
  <thead>
    <tr>
      <th class="text-center">#</th>
      <th class="w-2/12">Date</th>
      <th>Assets</th>
      <th>Status</th>
      <th class="w-11/12">Remark</th>
      <th></th>
    </tr>
  </thead>
  <tbody>
    {#if importSessions}
      {#each importSessions as session, idx}
        <tr class:active={selectedRowIdx === idx} on:click={(e) => handleRowClick(e, idx)} on:dblclick={() => handleDoubleClick(session.id)}>
          <td class="text-center">{session.id}</td>
          <td>{getHumanDate(session.created_at)}</td>
          <td>{session.assets_count}</td>
          <td class="text-center">
            {#if session.status === 'error'}
              ❌
            {:else if session.status === 'partial'}
              ⚠️
            {:else}
              ✅
            {/if}
          </td>
          <td>{session.remark || ''}</td>
          <td>
            <button on:click={() => handleDetailsClick(session)}>
              <span class="icon icon-info"></span>
            </button>
          </td>
        </tr>
      {/each}
    {/if}
  </tbody>
</table>
