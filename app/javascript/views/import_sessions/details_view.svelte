<script>
  import { DateTime } from 'luxon'

  export let importSession

  function getHumanDate (isoDate) {
    const dt = DateTime.fromISO(isoDate)
    return dt.toLocaleString(DateTime.DATETIME_FULL)
  }
</script>

<div class="w-full h-full p-4 bg-theme-light-gray">
  <div class="w-full text-xs">
    <span class="text-gray-700 font-medium">Date Created:</span>
    <span class="inline-block text-gray-600">
      {getHumanDate(importSession.created_at)}
    </span>
  </div>
  <div class="w-full text-xs">
    <span class="text-gray-700 font-medium">Status:</span>
    <span class="inline-block text-gray-600">
      {importSession.status}
    </span>
  </div>
  <div class="w-full text-xs">
    <span class="text-gray-700 font-medium">Number of assets:</span>
    <span class="inline-block text-gray-600">
      {importSession.assets_count}
    </span>
  </div>
  <div class="w-full text-xs">
    <span class="text-gray-700 font-medium">Not allowed assets count:</span>
    <span class="inline-block text-gray-600">
      {importSession.not_allowed_count}
    </span>
  </div>

  {#if importSession.details.errors}
    <span class="block mt-2 text-xs font-gray-700 font-medium">Errors:</span>

    <table class="w-full h-32 mt-1 border overflow-scroll">
      <tbody>
        {#each importSession.details.errors as error}
          <tr class="w-full h-4 border-b overflow-x-scroll">
            <td class="w-1/4 px-2">{error.file}</td>
            <td class="max-w-0 px-2 whitespace-normal">{error.message}</td>
          </tr>
        {/each}
        <tr>
          <td></td>
          <td></td>
        </tr>
      </tbody>
    </table>
  {/if}
</div>
