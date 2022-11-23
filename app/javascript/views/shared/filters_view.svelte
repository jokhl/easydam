<script>
  import { onMount, onDestroy, createEventDispatcher } from 'svelte'
  import {
    registerKeyBindings,
    deleteKeyBindings,
    updatePagination
  } from '../../utilities'
  import { visibleAssetsStore, searchQueryStore } from '../../stores'

  import SearchController from '../../controllers/search_controller'

  import FilterGroupComponent from '../../components/filter_group_component.svelte'
  import ToggleComponent from '../../components/toggle_component.svelte'

  export let isVisible

  const dispatch = createEventDispatcher()
  const keyBindingsID = 'filtersView'
  const keyBindings = []
  const filterGroups = []
  const booleans = []

  let builderElem
  let localIdx = 0
  let paginationComponent
  let query
  let unsubscribe

  $: if (isVisible) {
    registerKeyBindings(keyBindingsID, keyBindings)
  } else {
    deleteKeyBindings(keyBindingsID)
  }

  onMount(() => {
    unsubscribe = searchQueryStore.subscribe(newQuery => {
      query = newQuery
    })
  })

  onDestroy(() => {
    unsubscribe()
  })

  function handleAddFilterGroupClick () {
    // Add a boolean toggle only after the first filter.
    if (filterGroups.length > 0) addBoolean(localIdx)

    const exprGroupComponent = new FilterGroupComponent({
      target: builderElem,
      props: {
        idx: localIdx,
        className: 'w-1/2 ml-2 pl-4 border-l-4'
      }
    })

    exprGroupComponent.$on('destroy', () => {
      // We need to search for the component in the filters array because if
      // we used 'idx' for example from outside this callback, there would be
      // not guarantee that it will stay the same. Imagine removing a filter
      // from the middle of the filters array. all the 'idx' of the following
      // filters would shift 1 unit back.
      const idx = filterGroups.findIndex(f => f.idx === exprGroupComponent.idx)
      removeFilterGroup(idx)
    })

    filterGroups.push(exprGroupComponent)
    localIdx++
  }

  function addBoolean (idx) {
    const booleanComponent = new ToggleComponent({
      target: builderElem,
      props: {
        inputName: `booleans[${idx}]`,
        className: 'inline-block w-24 my-3',
        options: [
          { key: '&&', value: 'AND'},
          { key: '||', value: 'OR'},
        ]
      }
    })
    booleans.push(booleanComponent)
  }

  function removeFilterGroup (idx) {
    const exprGroupComponent = filterGroups.splice(idx, 1)[0]

    // It's okay to use 'idx' here because they're correlated.
    // We use 'idx - 1' because there is no boolean added for the first
    // filter.
    if (booleans[idx - 1]) {
      const lastBooleanComponent = booleans.splice(idx - 1, 1)[0]
      lastBooleanComponent.$destroy()
    }

    // Special case if the user removed the first filter.
    if (idx === 0 && booleans[0]) {
      const lastBooleanComponent = booleans.splice(0, 1)[0]
      lastBooleanComponent.$destroy()
    }

    // Needs to be last or above won't work.
    exprGroupComponent.$destroy()
  }

  function handleApplyClick () {
    const queryTree = buildQueryTree(filterGroups, booleans)
    $searchQueryStore = queryTree
    executeSearch()
  }

  function buildQueryTree (filters, booleans) {
    if (filters.length === 1) {
      return filters[0].getExpression()
    } else if (filters.length > 1) {
      const leftNode = filters.shift()
      const operator = booleans.shift()
      return {
        type: 'sub_query',
        operands: [
          leftNode.getExpression(),
          buildQueryTree(filters, booleans)
        ],
        operator: operator.getValue()
      }
    } else {
      return {}
    }
  }

  function executeSearch (pageNumber = 1) {
    SearchController.search(query, pageNumber)
      .then(search => {
        $visibleAssetsStore = search.hits
        handlePagination(search.pagination)
        dispatch('close')
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

<div class="py-3 px-4">
  <h5 class="mb-2 font-bold">Filters</h5>

  <div class="w-full" bind:this={builderElem}>
  </div>

  <div class="flex items-center mt-6 mb-3">
    <button class="btn btn-default" on:click={handleAddFilterGroupClick}>
      <span class="mr-1 icon icon-plus"></span>
      Add filter
    </button>

    <button class="ml-2 btn btn-positive" on:click={handleApplyClick}>
      Apply
    </button>
  </div>
</div>
