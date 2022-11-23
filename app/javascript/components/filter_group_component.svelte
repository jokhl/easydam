<script>
  import { onMount, createEventDispatcher } from 'svelte'

  import FilterExpressionComponent from './filter_expression_component.svelte'
  import ToggleComponent from './toggle_component.svelte'

  export let idx
  export let className = ''
  export function getExpression () {
    return buildExpressionTree(filters, booleans)
  }

  const dispatch = createEventDispatcher()
  const filters = []
  const booleans = []

  let containerElem
  let localIdx = 0

  onMount(() => {
    addFilterExpression()
  })

  function buildExpressionTree (filters, booleans) {
    if (filters.length === 1) {
      return filters[0].getExpression()
    } else {
      const leftNode = filters.shift()
      const operator = booleans.shift()
      return {
        type: 'sub_query',
        operands: [
          leftNode.getExpression(),
          buildExpressionTree(filters, booleans)
        ],
        operator: operator.getValue()
      }
    }
  }

  function addFilterExpression () {
    // Add a boolean toggle only after the first filter.
    if (filters.length > 0) addBoolean(localIdx)

    const component = new FilterExpressionComponent({
      target: containerElem,
      props: {
        idx: localIdx,
        className: 'flex items-center py-2 px-1'
      }
    })

    component.$on('destroy', () => {
      // For explanation, see same callback in 'filter_view.svelte'.
      const idx = filters.findIndex(f => f.idx === component.idx)
      removeFilter(idx)

      // If user destroyed all the filters in this group, let's emit an event
      // to destroy the group as well.
      if (filters.length === 0) {
        dispatch('destroy')
      }
    })

    filters.push(component)
    localIdx++
  }

  function addBoolean (localIdx) {
    const booleanComponent = new ToggleComponent({
      target: containerElem,
      props: {
        inputName: `group[${idx}]booleans[${localIdx}]`,
        className: 'inline-block w-24 ml-2',
        options: [
          { key: '&&', value: 'AND'},
          { key: '||', value: 'OR'},
        ]
      }
    })
    booleans.push(booleanComponent)
  }

  function removeFilter (idx) {
    const exprComponent = filters.splice(idx, 1)[0] // remove from filters array

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
    exprComponent.$destroy()
  }
</script>

<svelte:options accessors={true} />

<div class="{className}">
  <div class="bg-gray-100 rounded-md" bind:this={containerElem}>
  </div>
  
  <button class="mt-2 btn btn-default" on:click={addFilterExpression}>
    <span class="mr-1 icon icon-plus"></span>
    Add filter in this group
  </button>
</div>
