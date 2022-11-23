<script>
  import { createEventDispatcher } from 'svelte'
  import { FILTER_FIELDS, FILTER_OPERATORS_BY_TYPE } from '../constants'

  import InputSelectComponent from './input_select_component.svelte'

  export let idx
  export let className = ''
  export let field
  export let value
  export let operator
  export function getExpression () {
    return {
      type: field.type,
      operands: [ field.key, value ],
      operator: operator.key
    }

    /*
    switch (field.type) {
      case 'integer':
        return getFilterForInteger()
      case 'string':
        return getFilterForString()
      default:
        console.error(`Unknown field type: ${field.type}.`)
        break
    }*/
  }
  
  const dispatch = createEventDispatcher()
  const operatorCollectionEmpty = 'Please select a field first.'

  let fieldComponent, operatorComponent

  $: if (field) {
    operatorComponent.$set({
      collection: FILTER_OPERATORS_BY_TYPE[field.type]
    })
    operatorComponent.selectItem(0)

    // When the user selects a field with a callback, it's a special case of UX.
    if (field.params && field.params.callback) {
      field.params.callback(fieldComponent)
    }
  }

  function handleDeleteClick () {
    dispatch('destroy')
  }
</script>

<svelte:options accessors={true} />

<div class="{className}">
  <InputSelectComponent className="flex-grow mx-1" collection={FILTER_FIELDS} editable={true} placeholder='Type a field name...' bind:selectedItem={field} bind:this={fieldComponent} />

  <InputSelectComponent className="w-48 mx-1" emptyCollectionMessage={operatorCollectionEmpty} bind:selectedItem={operator} bind:this={operatorComponent} />

  {#if field && (field.type === 'list' || field.type === 'nested')}
    <InputSelectComponent className="mx-1" editable={true} bind:value={value} />
  {:else}
    <input type="text" class="mx-1 py-1 px-2 bg-white border shadow-sm rounded-md focus:ring-2 ring-blue-400 text-gray-800 text-sm outline-none" bind:value={value}>
  {/if}
  
  <button class="ml-2 mr-3 text-gray-500 hover:text-red-500" on:click={handleDeleteClick}>
    <span class="icon icon-cancel"></span>
  </button>
</div>
