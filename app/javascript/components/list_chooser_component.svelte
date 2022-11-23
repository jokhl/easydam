<script>
import { each } from "svelte/internal";


  /* Reference: https://www.javascripttutorial.net/web-apis/javascript-drag-and-drop */

  export let leftList = []
  export let leftTitle
  export let rightList = []
  export let rightTitle
  export let keyField
  export let valueField
  export let className = ''
  export let listsClass = ''
  export let width = 'w-64', height = 'h-64'
  export let isForm = false
  export let name = ''

  let leftListElem, rightListElem, selectedItem, selectedItemIdx

  function handleDragStart (e, item) {
    e.dataTransfer.setData('text/plain', e.target.dataset['idx'])
    handleItemSelection(item)

    // Hack to hide the dragged element
    // https://www.javascripttutorial.net/web-apis/javascript-drag-and-drop
    setTimeout(() => {
      e.target.classList.add('hidden')
    }, 0)
  }

  function handleDragEnd (e) {
    e.target.classList.remove('hidden')
  }

  function handleDrop (e) {
    e.preventDefault()
    removeBorders(e.target)

    const idx = parseInt(e.dataTransfer.getData('text/plain'))

    if (rightListElem.contains(e.target)) {
      moveItem('toRight', idx)
    } else {
      moveItem('toLeft', idx)
    }
  }

  function handleDragEnter (e) {
    e.preventDefault()
    addBorders(e.target)
  }

  function handleDragOver (e) {
    e.preventDefault()
    addBorders(e.target)
  }

  function handleDragLeave (e) {
    removeBorders(e.target)
  }

  function addBorders (elem) {
    if (leftListElem.contains(elem)) {
      leftListElem.classList.add('border-blue-600')
    } else if (rightListElem.contains(elem)) {
      rightListElem.classList.add('border-blue-600')
    }
  }

  function removeBorders (elem) {
    if (leftListElem.contains(elem)) {
      leftListElem.classList.remove('border-blue-600')
    } else if (rightListElem.contains(elem)) {
      rightListElem.classList.remove('border-blue-600')
    }
  }

  // This is not DRY because Javascript does not offer "pass by reference".
  function moveItem(direction, idx = selectedItemIdx) {
    let item

    if (idx !== undefined) {
      if (direction === 'toRight') {
        item = leftList[idx]

        // If the user clicked on the wrong button to move items, there will be
        // a mismatch between the retrieved item and the selected one. This
        // condition protects against this scenario.
        if (item === selectedItem) {
          // Append the item to the destination list.
          rightList = [...rightList, item]

          // Remove the item from source list and provoke a refresh from Svelte
          // by manually reassigning the source list because the splice method
          // removes the item in-place.
          leftList.splice(idx, 1)
          leftList = leftList

          // Update the index of the selected item
          selectedItemIdx = rightList.indexOf(item)
        }
      // For comments, see above.
      } else {
        item = rightList[idx]

        if (item === selectedItem) {
          leftList = [...leftList, item]
          rightList.splice(idx, 1)
          rightList = rightList
          selectedItemIdx = leftList.indexOf(item)
        }
      }
    }
  }

  function handleItemSelection (item, idx) {
    if (selectedItem) selectedItem.selected = false

    // Maybe the user selected the already selected item, then her intention
    // was to unselect it so we won't do that.
    if (item !== selectedItem) {
      item.selected = true
      selectedItem = item
      selectedItemIdx = idx
    }

    // We must do that in order to trigger a refresh from Svelte.
    leftList = leftList
    rightList = rightList
  }
</script>

<style>
  .active {
    color: #fff;
    background-color: #116cd6;
  }
</style>

<div class="{className} flex">
  <div>
    {#if leftTitle}
      <h5 class="py-1 px-2 bg-theme-light-gray border-t border-r border-l text-gray-500 text-xs font-medium">
        {leftTitle}
      </h5>
    {/if}
    <ul class="{width} {height} border overflow-y-scroll select-none {listsClass}" on:dragenter={handleDragEnter} on:dragover={handleDragOver} on:dragleave={handleDragLeave} on:dragend={handleDragEnd} on:drop={handleDrop} bind:this={leftListElem}>
      {#each leftList as item, idx}
        <li class="py-0.5 px-2" class:active={item.selected} draggable="true" data-idx={idx} on:click={(e) => handleItemSelection(item, idx)} on:dragstart={(e) => handleDragStart(e, item)}>
          {item[valueField]}
        </li>
      {/each}
    </ul>
  </div>

  <div class="flex flex-col w-16 justify-center">
    <button class="icon icon-right-open" on:click|preventDefault={() => moveItem('toRight')}></button>
    <button class="icon icon-left-open" on:click|preventDefault={() => moveItem('toLeft')}></button>
  </div>

  <div>
    {#if rightTitle}
      <h5 class="py-1 px-2 bg-theme-light-gray border-t border-r border-l text-gray-500 text-xs font-medium">
        {rightTitle}
      </h5>
    {/if}
    <ul class="{width} {height} border overflow-y-scroll select-none {listsClass}" on:dragenter={handleDragEnter} on:dragover={handleDragOver} on:dragleave={handleDragLeave} on:dragend={handleDragEnd} on:drop={handleDrop} bind:this={rightListElem}>
      {#each rightList as item, idx}
        <li class="py-0.5 px-2" class:active={item.selected} draggable="true" data-idx={idx} on:click={(e) => handleItemSelection(item, idx)} on:dragstart={(e) => handleDragStart(e, item)}>
          {item[valueField]}
        </li>
      {/each}
    </ul>
  </div>
</div>

{#if isForm}
  {#each rightList as item}
    <input type="hidden" name={name} value={item[valueField]}>
  {/each}
{/if}
