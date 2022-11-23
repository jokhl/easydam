import API from '../api'

import AssetsIndexView from '../views/assets/index_view.svelte'

export default {
  routes: [
    { path: '/', view: AssetsIndexView }
  ],
  getAssets: function (page = 1) {
    return new Promise((resolve, reject) => {
      API.call({ url: `/api/assets?page=${page}` })
        .then(assets => resolve(assets))
        .catch(error => console.error(error))
    })
  }
}
