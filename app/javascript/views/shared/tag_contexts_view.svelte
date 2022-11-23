<script>
  import { onMount } from 'svelte'
  import { tagContextsStore } from '../../stores'
  import { notify } from '../../utilities'

  import TagsController from '../../controllers/tags_controller'
  
  import TextFieldComponent from '../../components/text_field_component.svelte'

  let tagContexts = $tagContextsStore
  let selectedIdx
  let selectedRowElem
  let tableBodyElem
  let emptyRowElem
  let newTextFieldComponent

  onMount(() => {
    TagsController.getTagContexts()
      .then(data => ($tagContextsStore = data))
  })

  function handleAddClick () {
    if (newTextFieldComponent) {
      newTextFieldComponent.focus()
    } else {
      const trElem = document.createElement('tr')
      trElem.classList.add('h-4')
      const tdElem = document.createElement('td')
      tdElem.classList.add('px-0')
      trElem.appendChild(tdElem)
      tableBodyElem.insertBefore(trElem, emptyRowElem)
      newTextFieldComponent = new TextFieldComponent({
        target: tdElem,
        props: {
          className: 'w-full border outline-none focus:ring-2 ring-blue-200',
          isFocus: true
        }
      })
      newTextFieldComponent.$on('saveNewValue', (e) => {
        saveToAPI(e.detail.value)
        newTextFieldComponent.$destroy()
        newTextFieldComponent = undefined
        trElem.remove()
      })
      newTextFieldComponent.$on('cancel', (e) => {
        newTextFieldComponent.$destroy()
        newTextFieldComponent = undefined
        trElem.remove()
      })
    }
  }

  function handleGeneralClick (e) {
    if (e.target !== selectedRowElem) {
      selectedIdx = undefined
      selectedRowElem = undefined
    }
  }

  function handleSelectClick (idx, e) {
    selectedIdx = idx
    selectedRowElem = e.target
  }

  function saveToAPI (label) {
    TagsController.createTagContext(label)
      .then(newTagContext => {
        tagContexts = [...tagContexts, newTagContext]
        $tagContextsStore = tagContexts
      })
      .catch(res => {
        notify({
          duration: 5000,
          props: {
            title: 'Error',
            subtitle: res.error,
            status: 'error'
          }
        })
      })
  }
</script>

<div class="w-full h-full p-4 bg-theme-light-gray" on:click={handleGeneralClick}>
  <p class="text-sm text-gray-600">Here are the available tags:</p>

  <table class="w-full h-32 mt-3 border overflow-scroll">
    <tbody bind:this={tableBodyElem}>
      {#each tagContexts as tc, idx}
        <tr class="h-4" class:active={idx === selectedIdx}>
          <td class="px-2 select-none" on:click={(e) => handleSelectClick(idx, e)}>{tc.label}</td>
        </tr>
      {/each}
      <tr bind:this={emptyRowElem}>
        <td></td>
      </tr>
    </tbody>
  </table>
  <div class="flex justify-end p-0 border-r border-b border-l">
    <button class="flex items-center justify-center w-7 h-6 border-l text-gray-600 outline-none" on:click={handleAddClick}>
      <span class="icon icon-plus"></span>
    </button>
    <button class="flex items-center justify-center w-7 h-6 border-l text-gray-600 outline-none">
      <span class="icon icon-minus"></span>
    </button>
  </div>
</div>
