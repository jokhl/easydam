import WindowComponent from './components/window_component.svelte'
import PaginationNavComponent from './components/pagination_nav_component.svelte'
import { paginationComponentStore } from './stores'
import { get } from 'svelte/store'

export function formatBytes (bytes, decimals = 2) {
  if (bytes === 0) return '0 Bytes'

  const k = 1024
  const dm = decimals < 0 ? 0 : decimals
  const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB']

  const i = Math.floor(Math.log(bytes) / Math.log(k))

  return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i]
}

export function openWindow (opts = {}) {
  if (opts.view) {
    const windowComponent = new WindowComponent({
      target: document.body,
      props: opts
    })
    return windowComponent
  } else {
    console.error('ERROR: No page given!')
  }
}

export function notify (opts) {
  const event = new CustomEvent('notifications/new', { detail: opts })
  window.dispatchEvent(event)
}

export function isInViewport (elem) {
  const bounding = elem.getBoundingClientRect()
  return bounding.top >= 0 && bounding.bottom <= window.innerHeight
}

export function registerKeyBindings (id, keyBindings) {
  // console.log(`registered keybindings for '${id}'`)
  window.keyBindings.push({
    id: id,
    keyBindings: keyBindings
  })
}

export function deleteKeyBindings (id) {
  // console.log(`deleted keybindings for '${id}'`)
  const idx = window.keyBindings.findIndex(k => k.id === id)
  if (idx >= 0) window.keyBindings.splice(idx, 1)
}

export function redirectKeyBindTo (e, id) {
  const idx = window.keyBindings.findIndex(k => k.id === id)
  if (idx >= 0) handleKeyDown(e, window.keyBindings[idx])
}

export function handleKeyDown (e, activeComponent) {
  const isGlobal = false

  for (let i = 0; i < window.globalKeyBindings.length; i++) {
    if (_handleKeyBinding(e, window.globalKeyBindings[i])) break
  }

  if (!isGlobal && window.keyBindings.length > 0) {
    if (!activeComponent) {
      activeComponent = window.keyBindings[window.keyBindings.length - 1]
    }

    const activeKeyBindings = activeComponent.keyBindings

    for (let i = 0; i < activeKeyBindings.length; i++) {
      if (_handleKeyBinding(e, activeKeyBindings[i])) break
    }
  }
}

export function updatePagination (pagination) {
  let component = get(paginationComponentStore)

  if (component) {
    component.$set({ data: pagination })
  } else {
    component = _setupPagination(pagination)
    paginationComponentStore.set(component)
  }

  return component
}

// Adapted from https://github.com/sveltejs/svelte/issues/2968
export function range (from, to) {
  if (from > to) throw new Error('first argument must be smaller then second one')
  if (from !== parseInt(from) || to !== parseInt(to)) throw new Error('arguments must be of type integer')
  if (from < 0 || to < 0) throw new Error('arguments must be positive')

  const elements = to - from + 1
  return [...Array(elements)].map((_, i) => (i += from))
}

// This function returns true if the key binding matched.
function _handleKeyBinding (e, keyBinding) {
  if (e.keyCode === keyBinding.keyCode) {
    if (keyBinding.meta && !e.metaKey) return false

    keyBinding.callback(e)
    return true
  }

  return false
}

function _setupPagination (pagination) {
  const navElem = document.querySelector('#pagination_nav')
  const paginationNavComponent = new PaginationNavComponent({
    target: navElem,
    props: {
      data: pagination
    }
  })

  return paginationNavComponent
}
