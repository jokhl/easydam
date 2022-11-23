<script>
  import Winbox from 'winbox/src/js/winbox.js'
  import { onMount, onDestroy, createEventDispatcher } from 'svelte'
  import { deleteKeyBindings } from '../utilities'

  export let view
  export let title = ''
  export let x = 'center'
  export let y = 'center'
  export let fullSizeable = false
  export let maximizeable = false
  export let minimizeable = false
  export let resizeable = true
  export let header = true
  export let className = ''
  export let width = '50%'
  export let height = '50%'
  export let maxWidth
  export let maxHeight
  export let props = {}
  export let containerClass = ''
  export let focus = false
  export let modal = false
  export function close () {
    windowInstance.close()
  }
  export function resize (width, height) {
    if (windowInstance) {
      windowInstance.resize(width, height)
      windowInstance.move(x, y) // must reposition after a resize
    }
  }

  const dispatch = createEventDispatcher()

  let windowInstance
  let viewInstance
  let containerElem

  function handleChildResize (e) {
    if (!windowInstance.max) {
      windowInstance.width += e.detail.deltaWidth || 0
      windowInstance.height += e.detail.deltaHeight || 0
      windowInstance.resize()
    }
  }

  onMount(() => {
    if (width == 'auto') {
      width = `${containerElem.offsetWidth}px`
    }

    windowInstance = new Winbox({
      title: title,
      width: width,
      height: height,
      x: x,
      y: y,
      modal: modal,
      class: [
        fullSizeable ? '' : 'no-full',
        maximizeable ? '' : 'no-max',
        minimizeable ? '' : 'no-min',
        resizeable ? '' : 'no-resize',
        header ? '' : 'no-header',
        className
      ],
      mount: containerElem,
      onclose: function () {
        // We need to manually remove the component from the DOM because Winbox
        // won't as it does not know about it.
        containerElem.remove()

        if (modal) {
          window.removeEventListener('click', handleWindowClick)
        }

        dispatch('didClose')
      },
      onresize: function (width, height) {
        let mustResize = false

        if (maxWidth) {
          if (maxWidth.endsWith('%')) {
            const pct = parseFloat(maxWidth) / 100
            const maxWidthValue = window.innerWidth * pct
            if (width > maxWidthValue) {
              const ratio = this.height / this.width
              this.width = maxWidthValue
              this.height = ratio * maxWidthValue
              mustResize = true
            }
          }
        }

        if (maxHeight) {
          if (maxHeight.endsWith('%')) {
            const pct = parseFloat(maxHeight) / 100
            const maxHeightValue = window.innerHeight * pct
            if (height > maxHeightValue) {
              const ratio = this.width / this.height
              this.width = maxHeightValue * ratio
              this.height = maxHeightValue
              mustResize = true
            }
          }
        }

        if (mustResize) {
          this.resize()
          this.move(x, y) // must reposition the window after a resize
        }
      }
    })

    // This must be done AFTER creating the windowInstance.
    if (width == 'auto') {
      autoResizeWidth()
    }

    if (height == 'auto') {
      autoResizeHeight()
    }

    if (focus) {
      setTimeout(() => {
        windowInstance.focus()
      }, 250)
    }

    if (modal) {
      window.addEventListener('click', handleWindowClick)
    }
  })

  onDestroy(() => {
    if (windowInstance) windowInstance.close()
  })

  function autoResizeWidth () {
    windowInstance.width = windowInstance.body.width
    windowInstance.resize()
    // We must manually move to place because we changed the width.
    windowInstance.move(x, y)
  }

  function autoResizeHeight () {
    const windowHeaderElem = windowInstance.dom.firstChild
    const windowHeaderHeight = windowHeaderElem ? windowHeaderElem.offsetHeight : 0
    // We add 2 pixels to take into account a couple borders
    windowInstance.height = windowHeaderHeight + containerElem.offsetHeight + 2
    windowInstance.resize()
    // We must manually move to place because we changed the height.
    windowInstance.move(x, y)
  }

  function handleWindowClick (e) {
    if (!windowInstance.body.contains(e.target)) {
      handleCloseWindow()
    }
  }

  function handleCloseWindow () {
    // This is useful if the caller did not delete the keybindings of the view.
    // Also, if the window is closed from here, e.g. by handleWindowClick.
    if (viewInstance.keyBindingsID) {
      deleteKeyBindings(viewInstance.keyBindingsID)
    }

    windowInstance.close()
  }
</script>

<div class="{containerClass}" bind:this={containerElem}>
  <svelte:component this={view} {...props} on:childResize={handleChildResize} on:closeWindow={handleCloseWindow} bind:this={viewInstance} />
</div>
