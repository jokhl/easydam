<script>
  import { range } from '../utilities'
  
  export let data
  // How many links to show to the left/right of current page number
  export let showLinksCount = 2
  export let onPageChange = (pageNumber) => {}

  const statsElem = document.querySelector('#pagination_stats')

  let rangeStart, rangeEnd, startingAt, endingAt

  $: rangeStart = data.current_page - showLinksCount
  $: if (rangeStart < 1) rangeStart = 1

  $: rangeEnd = data.current_page + showLinksCount
  $: if (rangeEnd > data.total_pages) rangeEnd = data.total_pages

  $: startingAt = data.offset + 1
  $: endingAt = data.offset + data.count_per_page

  $: if (data) {
    if (data.took !== undefined ) {
      if (data.total > 0) {
        statsElem.textContent = `${data.total} results (${data.took} ms) / Showing ${startingAt} - ${endingAt}`
      } else {
        statsElem.textContent = `${data.total} results (${data.took} ms)`
      }
    } else {
      statsElem.textContent = `${data.total} assets / Showing ${startingAt} - ${endingAt}`
    }
  }

  function handlePageChangeClick (pageNumber) {
    onPageChange(pageNumber)
  }

  function handleNextPageClick () {
    handlePageChangeClick(data.current_page + 1)
  }

  function handlePrevPageClick () {
    handlePageChangeClick(data.current_page - 1)
  }
</script>

{#if data.total_pages > 0}
  <nav class="flex items-center justify-center w-full">
    {#if data.current_page > 1}
      <button class="mx-0.5 px-1 text-blue-500 text-lg leading-none outline-none focus:outline-none" on:click={handlePrevPageClick}>
        <span class="icon icon-left-open-mini"></span>
      </button>
    {/if}

    {#each range(rangeStart, rangeEnd) as pageNumber}
      {#if pageNumber === data.current_page}
        <span class="mx-0.5 px-1 border-2 border-blue-400 rounded-md text-blue-400 font-medium select-none">
          {pageNumber}
        </span>
      {:else}
        <button class="mx-0.5 px-1 text-gray-400 hover:text-gray-800 outline-none focus:outline-none" on:click={() => handlePageChangeClick(pageNumber)}>
          {pageNumber}
        </button>
      {/if}
    {/each}

    {#if data.current_page < data.total_pages}
      <button class="mx-0.5 px-1 text-blue-500 text-lg leading-none outline-none focus:outline-none" on:click={handleNextPageClick}>
        <span class="icon icon-right-open-mini"></span>
      </button>
    {/if}
  </nav>
{/if}
