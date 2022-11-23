import IndexPage from '../views/import_sessions/index_view.svelte'
import ShowPage from '../views/import_sessions/show_view.svelte'

export default {
  routes: [
    { path: '/import_sessions', view: IndexPage },
    { path: '/import_sessions/:id', view: ShowPage }
  ]
}
