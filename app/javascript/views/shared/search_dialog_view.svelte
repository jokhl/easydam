<script>
  import { onMount, createEventDispatcher } from 'svelte'
  import {
    registerKeyBindings,
    deleteKeyBindings,
    updatePagination
  } from '../../utilities'
  import Fuse from 'fuse.js'
  import { visibleAssetsStore, searchQueryStore } from '../../stores'

  import TagsController from '../../controllers/tags_controller'
  import SearchController from '../../controllers/search_controller'

  export let onSearchDone = took => {}

  const dispatch = createEventDispatcher()
  const keyBindingsID = 'search_dialog'
  const keyBindings = [
    {
      keyCode: 27,
      callback: close
    }
  ]
  const resizeObserver = new ResizeObserver(entries => {
    let deltaHeight = entries[0].target.offsetHeight - currentHeight

    dispatch('childResize', {
      deltaHeight: deltaHeight
    })

    // We need to update the height so the sign of the next deltas
    // will show in which direction the change is happening.
    currentHeight = entries[0].target.offsetHeight
  })

  let inputElem
  let contentElem
  let inputValue
  let mode = 'help'
  let listTitle = ''
  let list = []
  let listResults = []
  let listSelectCallback
  let listItemKey
  let listSearchKey
  let currentHeight
  let fuseInstance
  let listQuery
  let selectedIdx
  let queryElem
  let queryElemList = []
  let query
  let unsubscribe
  let selectedFilterIdx
  let paginationComponent

  onMount(() => {
    unsubscribe = searchQueryStore.subscribe(newQuery => {
      query = newQuery
    })

    // Hack to make it work
    setTimeout(() => {
      inputElem.focus()
    }, 0)

    registerKeyBindings(keyBindingsID, keyBindings)

    currentHeight = contentElem.offsetHeight
    resizeObserver.observe(contentElem)
  })

  function close () {
    dispatch('closeWindow')
    deleteKeyBindings(keyBindingsID)
    unsubscribe()
  }

  function handleKeyUp (e) {
    switch (e.keyCode) {
      // #
      case 51:
        TagsController.getTagContexts()
          .then(data => {
            initTagContextInput()
            handleListData(data)
          })
        break
      default:
        switch (mode) {
          case 'list':
            const match = inputValue.match(/#([\w\s]*)$/)

            if (match && fuseInstance) {
              listQuery = match[1]

              // If user did not enter a query after the '#' then we want to
              // show all the tag contexts.
              if (listQuery.length > 0) {
                listResults = fuseInstance.search(`'${listQuery}`)
              } else {
                listResults = list.map(item => {
                  return { item: item }
                })
              }
            }
            break
          default:
            break
        }
        break
    }
  }

  function handleKeyDown (e) {
    switch (e.keyCode) {
      // Backspace
      case 8:
        // If there is no text in the search bar, it means the user intends to
        // remove his last chosen search criteria.
        if (inputValue === '') {
          exitMode()
        }
        break
      // Enter
      case 13:
        e.preventDefault()
        switch (mode) {
          case 'list':
            const selectedItem = listResults[selectedIdx].item
            listSelectCallback(selectedItem)
            break
          default:
            break
        }
        break
      // Arrow up
      case 38:
        e.preventDefault()
        switch (mode) {
          case 'list':
            handleArrowUp()
            break
          default:
            break
        }
        break
      // Arrow down
      case 40:
        e.preventDefault()
        switch (mode) {
          case 'list':
            handleArrowDown()
            break
          default:
            break
        }
        break
      default:
        break
    }
  }

  function handleArrowUp () {
    if (selectedIdx === undefined) {
      selectedIdx = listResults.length - 1
      return
    }

    if (selectedIdx === 0) selectedIdx = listResults.length - 1
    else selectedIdx = selectedIdx - 1
  }

  function handleArrowDown () {
    if (selectedIdx === undefined) {
      selectedIdx = 0
      return
    }

    if (selectedIdx === listResults.length - 1) selectedIdx = 0
    else selectedIdx = selectedIdx + 1
  }

  function initTagContextInput () {
    mode = 'list'
    listTitle = 'Please enter a tag name'
    listSelectCallback = handleTagContextSelection
    listSearchKey = 'label'
    listItemKey = 'label'
  }

  function initTagValueInput () {
    mode = 'list'
    listTitle = 'Please enter a tag value'
    listSelectCallback = handleTagValueSelection
    listSearchKey = 'value'
    listItemKey = 'value'
  }

  function handleTagContextSelection (tagContext) {
    inputValue = '' // empty the input field
    
    // Append the selected context to the search bar.
    const html = `
      <span class="py-1 px-2 bg-blue-400 rounded-md text-white">
        #${tagContext.label}
      <span>
    `
    queryElemList = [...queryElemList, html]
    
    selectedIdx = undefined // reset the selected list item index

    addFilter({
      key: 'tag',
      context: tagContext.key,
      label: tagContext.label,
      values: []
    })
    
    TagsController.getTagContext(tagContext.id)
      .then(data => {
        initTagValueInput()
        handleListData(data.all_tags)
      })
  }

  function handleTagValueSelection (tagValue) {
    addTagValue(tagValue.value)
    
    executeSearch()
  }

  function handleListData (data) {
    list = data
    listResults = list.map(item => {
      return { item: item }
    })

    // Search init

    const options = {
      isCaseSensitive: false,
      includeScore: true,
      shouldSort: true,
      useExtendedSearch: true,
      keys: [listSearchKey]
    }
    fuseInstance = new Fuse(list, options)
  }

  function colorize (text, pattern) {
    return text
      .replaceAll(pattern, `<span class="text-blue-400">${pattern}</span>`)
  }

  function exitMode () {
    if (mode === 'list') {
      queryElemList.pop()
      queryElemList = queryElemList // force Svelte refresh
      mode = 'help'
    }
  }

  function addFilter (filter) {
    const filterIdx = $searchQueryStore.filters
      .findIndex(f => f.key === filter.key)

    // Filter does not exist yet.
    if (filterIdx < 0) {
      $searchQueryStore.filters = [
        ...$searchQueryStore.filters,
        filter
      ]
      selectedFilterIdx = $searchQueryStore.filters.length - 1
    } else {
      selectedFilterIdx = filterIdx
    }
  }

  function addTagValue (tagValue) {
    const filter = $searchQueryStore.filters[selectedFilterIdx]
    // We need to do it like that because otherwise the store does not get
    // updated and thus it does not trigger a UI refresh.
    $searchQueryStore
      .filters[selectedFilterIdx]
      .values = [...filter.values, tagValue]
  }

  function removeFilter (idx) {
    $searchQueryStore.filters.splice(idx, 1)
    $searchQueryStore.filters = $searchQueryStore.filters // force refresh
    executeSearch()
  }

  function handleFilterRemoveClick (idx) {
    removeFilter(idx)
    exitMode()
  }

  function executeSearch (pageNumber = 1) {
    SearchController.search(query, pageNumber)
      .then(search => {
        exitMode()
        onSearchDone(search.took)
        $visibleAssetsStore = search.hits
        handlePagination(search.pagination)
      })
  }

  function handlePagination (pagination) {
    if (!paginationComponent) {
      paginationComponent = updatePagination(pagination)
      paginationComponent.$set({ onPageChange: handlePageChange })
    } else {
      paginationComponent.$set({ data: pagination })
    }
  }

  function handlePageChange (pageNumber) {
    executeSearch(pageNumber)
  }
</script>

<div class="w-full bg-gray-200">
  <div class="flex items-center py-4 px-2 border-b border-gray-300">
    <div class="pl-4 text-2xl text-gray-600 icon icon-search"></div>
    <div class="flex items-center pl-4" class:hidden={queryElemList.length === 0} bind:this={queryElem}>
      {#each queryElemList as elem}
        {@html elem}
      {/each}
    </div>
    <input type="text" class="flex-grow px-4 bg-gray-200 text-2xl text-gray-600 outline-none" on:keydown={handleKeyDown} on:keyup={handleKeyUp} bind:value={inputValue} bind:this={inputElem}>
  </div>
  <div bind:this={contentElem}>
    {#if query && query.filters.length > 0}
      <div class="flex items-center py-4 px-6 border-b border-gray-300 text-gray-200">
        <h5 class="font-medium text-gray-500">Filters:</h5>
        <ul class="flex-grow flex items-center ml-2">
          {#each query.filters as filter, idx}
            <li class="mx-1">
              {#if filter.context}
                <span class="py-1 px-2 bg-gray-800 rounded-md text-gray-50">
                  #{filter.label}
                  {#if filter.values}
                    <span class="text-gray-300">{filter.values.join(', ')}</span>
                  {/if}
                  <button class="ml-1 text-xs icon icon-cancel" on:click={() => handleFilterRemoveClick(idx)}></button>
                </span>
              {/if}
            </li>
          {/each}
        </ul>
      </div>
    {/if}
    {#if mode === 'help'}
      <div class="flex items-center py-4 px-6">
        <span class="py-1 px-3 bg-gray-800 rounded-md text-gray-100 text-lg">#</span>
        <span class="ml-2 text-gray-800 text-lg">to filter by tag</span>
      </div>
    {:else if mode === 'list'}
      <h5 class="pt-4 px-6 text-gray-500 font-medium">{listTitle}</h5>
      <ul class="w-full py-2 px-3">
        {#each listResults as result, idx}
          <li class="flex items-center justify-between w-full py-1.5 px-3 rounded-md text-gray-800 text-lg cursor-pointer" class:bg-gray-300={idx === selectedIdx}>
            <span>
              {@html colorize(result.item[listItemKey], query)}
            </span>
            <span class="text-xs text-gray-500" class:hidden={idx !== selectedIdx}>
              Select <span class="ml-1 py-0.5 px-1 bg-gray-500 rounded-md text-gray-300 icon icon-reply"></span>
            </span>
          </li>
        {/each}
      </ul>
    {/if}
  </div>
</div>
