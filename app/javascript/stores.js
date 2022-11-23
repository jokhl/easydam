import { writable } from 'svelte/store'

export const basketStore = writable([])
export const tagContextsStore = writable([])
export const visibleAssetsStore = writable([])
export const searchQueryStore = writable({
  filters: []
})
export const paginationComponentStore = writable()
export const pageTitleStore = writable('')
