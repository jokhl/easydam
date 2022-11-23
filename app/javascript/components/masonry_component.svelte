<script>
  import { onMount, onDestroy, createEventDispatcher } from 'svelte'
  import {
    isInViewport,
    registerKeyBindings,
    deleteKeyBindings
  } from '../utilities'
  import DragSelect from 'dragselect'

  export let id = ''
  export let bricks
  export let keyboardNavigation = false
  export let brickHeight
  export let gutterX = 0.25 // in rem
  export let gutterY = 2 // in rem
  export let className = ''
  export let doNotAminate = false
  export let containerElem
  export function showBrick(idx) {
    rectangles[idx].show = true
  }

  const dispatch = createEventDispatcher()
  const REM_FACTOR = parseFloat(
    getComputedStyle(document.documentElement).fontSize) // pixels for 1rem
  const keyBindingsID = 'masonry'
  const keyBindings = [
    { // Enter
      keyCode: 13,
      callback: () => {
        const selectedBrickIdx = parseInt(selectedBrickElems[0].dataset.idx)
        dispatch('doubleClick', { idx: selectedBrickIdx })
      }
    },
    { // Escape
      keyCode: 27,
      callback: () => {
        ds.clearSelection()
        dispatch('deselectBrick')
      }
    },
    { // Space
      keyCode: 32,
      callback: () => {
        const selectedBrickIdx = parseInt(selectedBrickElems[0].dataset.idx)
        dispatch('doubleClick', { idx: selectedBrickIdx })
      }
    },
    { // Arrow left
      keyCode: 37,
      callback: () => {
        const selectedBrickIdx = selectBrick(-1)
        dispatch('brickSelectionChange', { bricks: [selectedBrickIdx] })
      }
    },
    { // Arrow up
      keyCode: 38,
      callback: () => {
        const selectedBrickIdx = selectTopBottomBrick(-1)
        dispatch('brickSelectionChange', { bricks: [selectedBrickIdx] })
      }
    },
    { // Arrow right
      keyCode: 39,
      callback: () => {
        const selectedBrickIdx = selectBrick(1)
        dispatch('brickSelectionChange', { bricks: [selectedBrickIdx] })
      }
    },
    { // Arrow down
      keyCode: 40,
      callback: () => {
        const selectedBrickIdx = selectTopBottomBrick(1)
        dispatch('brickSelectionChange', { bricks: [selectedBrickIdx] })
      }
    },
    // Meta + i
    {
      meta: true,
      keyCode: 73,
      callback: (e) => {
        e.preventDefault()

        if (selectedBrickElems.length === 1) {
          const selectedBrickIdx = parseInt(selectedBrickElems[0].dataset.idx)
          dispatch('openFileInfo', { idx: selectedBrickIdx })
        }
      }
    }
  ]
  const resizeObserver = new ResizeObserver(() => {
    if (bricks && containerElem) {
      pack()
    }
  })

  let selectedBrickElems = []
  let rectangles
  let rows = [[]]
  let refreshesCount = 0
  let ds

  $: if (bricks && containerElem) {
    pack()
  }

  onMount(() => {    
    if (keyboardNavigation) {
      registerKeyBindings(keyBindingsID, keyBindings)
    }

    resizeObserver.observe(containerElem)
    initDragSelect()
  })

  onDestroy(() => {
    if (keyboardNavigation) {
      deleteKeyBindings(keyBindingsID)
    }
  })

  // Initially the container does not contain any children because they're not
  // rendered yet (still being fetched from the API and then redrawn in the
  // DOM).
  function initDragSelect () {
    ds = new DragSelect({
      selectables: containerElem.childNodes,
      area: containerElem,
      draggability: false,
      dragKeys: { up: [], down: [], left: [], right: [] }, // disable keyboard dragging
      selectedClass: 'masonry-selected'
    })
    // This event is fired ONLY when a brick is clicked.
    ds.subscribe('callback', ({ items, event }) => {
      selectedBrickElems = items
      dispatch('brickSelectionChange', {
        bricks: items.map(item => parseInt(item.dataset.idx))
      })
    })
    // This event is fired and a brick is either clicked or select with the
    // arrow keys.
    ds.subscribe('elementselect', ({ items, item }) => {
      selectedBrickElems = items
      dispatch('brickSelectionChange', {
        bricks: items.map(item => parseInt(item.dataset.idx))
      })
    })
    ds.subscribe('elementunselect', ({ items, item }) => {
      selectedBrickElems = items
    })
  }

  function addDragSelectItem (node) {
    ds.addSelectables(node)
  }

  function handleDoubleClick (idx) {
    dispatch('doubleClick', { idx: idx })
  }

  function selectBrick (step) {
    let selectedBrickIdx, selectedBrickElem

    if (selectedBrickElems.length === 0) {
      // Select the first brick is none is selected.
      selectedBrickElem = containerElem.querySelector('button')
      selectedBrickIdx = parseInt(selectedBrickElem.dataset.idx)
      ds.setSelection(selectedBrickElem)
      scrollToSelectedBrick(selectedBrickElem)
      return selectedBrickIdx
    }
    // If there are multiple bricks selected, move relative to the first one.
    else {
      selectedBrickIdx = parseInt(selectedBrickElems[0].dataset.idx)
    }
    
    const newIdx = selectedBrickIdx + step

    if (newIdx >= bricks.length) {
      // We reached the end of the list, let's manually set the index.
      selectedBrickIdx = 0
    } else if (newIdx < 0) {
      // We reached the start of the list, let's manually set the index.
      selectedBrickIdx = bricks.length - 1
    } else {
      selectedBrickIdx = newIdx
    }

    selectedBrickElem = containerElem
      .querySelector(`button[data-idx='${selectedBrickIdx}']`)
    ds.setSelection(selectedBrickElem)
    scrollToSelectedBrick(selectedBrickElem)
    
    return selectedBrickIdx
  }

  function selectTopBottomBrick (step) {
    let selectedBrickIdx, selectedBrickElem

    if (selectedBrickElems.length === 0) {
      // Select the first brick is none is selected.
      selectedBrickElem = containerElem.querySelector('button')
      selectedBrickIdx = parseInt(selectedBrickElem.dataset.idx)
      ds.setSelection(selectedBrickElem)
      scrollToSelectedBrick(selectedBrickElem)
      return selectedBrickIdx
    }
    // If there are multiple bricks selected, move relative to the first one.
    else {
      selectedBrickIdx = parseInt(selectedBrickElems[0].dataset.idx)
    }

    const selectedRectangle = rectangles[selectedBrickIdx]

    // Reminder: as row numbers begin at 1, we must deduct 1 to get an index.
    let newRowIdx = selectedRectangle.rowNumber + step - 1

    if (newRowIdx >= rows.length) newRowIdx = 0
    else if (newRowIdx < 0) newRowIdx = rows.length - 1

    let newIdx, commonSideLength, best
    let currentRectX0 = selectedRectangle.x
    let currentRectX1 = currentRectX0 + selectedRectangle.width
    let nextRectX0, nextRectX1

    // We look inside the new row for the brick that has the maximum common
    // side length with the currently selected brick.
    rows[newRowIdx].forEach(r => {
      nextRectX0 = r.x
      nextRectX1 = nextRectX0 + r.width

      // Check if the rectangles share a common side.
      if (nextRectX0 < currentRectX1 && nextRectX1 > currentRectX0) {
        if (nextRectX0 >= currentRectX0 && nextRectX1 <= currentRectX1) {
          // Next brick is shorter than or equal to current brick.
          commonSideLength = nextRectX1 - nextRectX0
        } else if (nextRectX0 < currentRectX0 && nextRectX1 > currentRectX1) {
          // Next brick is longer than the current brick.
          commonSideLength = currentRectX1 - currentRectX0
        } else if (nextRectX1 <= currentRectX1) {
          // Next brick is overlapping on the left of the current brick.
          commonSideLength = nextRectX1 - currentRectX0
        } else {
          // The only possible configuration left is when the next brick is
          // overlapping on the right of the current brick.
          commonSideLength = currentRectX1 - nextRectX0
        }

        if (best === undefined || commonSideLength > best) {
          best = commonSideLength
          newIdx = r.idx
        }
      }
    })

    // If there was no brick sharing a common side, then manually select first
    // or last brick.
    if (best === undefined) {
      newIdx = step > 0 ? 0 : bricks.length - 1
    }

    selectedBrickIdx = newIdx
    selectedBrickElem = containerElem
      .querySelector(`button[data-idx='${newIdx}']`)
    ds.setSelection(selectedBrickElem)
    scrollToSelectedBrick(selectedBrickElem)
    
    return selectedBrickIdx
  }

  function scrollToSelectedBrick (selectedBrickElem) {
    if (!isInViewport(selectedBrickElem)) selectedBrickElem.scrollIntoView()
  }

  function pack () {
    // Every time the brick array is empty, we reset the animation variables
    // because want to redo the animation when new bricks are received.
    if (bricks.length === 0) {
      refreshesCount = 0
      doNotAminate = false
    }

    // These animation variables help us animate on the first render (first
    // page) only and not between subsequent page changes.
    if (refreshesCount > 1) doNotAminate = true
    else refreshesCount++

    const containerWidth = containerElem.offsetWidth / REM_FACTOR // in rem
    let ratio, previous, currentX = 0, currentY = 0, offsetX = 0,
      rowCounter = 1, brickWidth

    // Reset
    rectangles = []
    rows = [[]]

    for (let i = 0; i < bricks.length; i++) {
      rectangles[i] = {}
      ratio = bricks[i].width / bricks[i].height
      brickWidth = brickHeight * ratio
      previous = rectangles[i - 1]
      currentX = ( previous?.x || gutterX ) + ( previous?.width || gutterX ) +
        gutterX
      offsetX = currentX + brickWidth

      if (offsetX >= containerWidth) {
        currentX = 2 * gutterX
        currentY = currentY + brickHeight + gutterY
        adjustRow(rowCounter) // must be before incrementing the row number
        rowCounter++
        rows.push([])
      }

      rectangles[i].width = brickWidth
      rectangles[i].height = brickHeight
      rectangles[i].x = currentX
      rectangles[i].y = currentY
      rectangles[i].rowNumber = rowCounter
      rectangles[i].idx = i
      rows[rowCounter - 1].push(rectangles[i])
    }
  }

  // This function evaluate the space left in the row and distributes it evenly
  // across the bricks of the row.
  function adjustRow (rowNumber) {
    const idx = rowNumber - 1 // reminder: row counter starts at 1
    const row = rows[idx]
    const lastRectangle = row[row.length - 1]
    const containerWidth = containerElem.offsetWidth / REM_FACTOR // in rem
    const spaceLeft = containerWidth - ( lastRectangle.x + lastRectangle.width )

    // We must substract the outside gutters of the whole masonry element from
    // the space left. Then we distribute the result across the bricks.
    const additionalWidth = ( spaceLeft - 2 * gutterX ) / row.length
    
    // We don't want to add margins to the first brick of the row.
    row[0].width += additionalWidth

    for (let i = 1; i < row.length; i++) {
      row[i].width += additionalWidth
      row[i].x += ( additionalWidth * i )
    }
  }

  function shouldAnimate (idx) {
    return !doNotAminate && (rectangles[idx].y * REM_FACTOR) < window.innerHeight
  }
</script>

<svelte:options accessors={true} />

<div id={id} class="relative {className} select-none-all" bind:this={containerElem}>
  {#each bricks as brick, idx}
    <button class="absolute transition-all transform-gpu duration-500 focus:outline-none" class:opacity-0={shouldAnimate(idx) && !rectangles[idx].show} style="width: {rectangles[idx].width}rem; height: {rectangles[idx].height}rem; transform: translate({!shouldAnimate(idx) || ( shouldAnimate(idx) && rectangles[idx].show ) ? `${rectangles[idx].x}rem, ${rectangles[idx].y}rem` : '0rem, 0rem'});" data-idx="{idx}" on:dblclick={() => handleDoubleClick(idx)} use:addDragSelectItem>

      <slot brick={brick} idx={idx} />

    </button>
  {/each}
</div>
