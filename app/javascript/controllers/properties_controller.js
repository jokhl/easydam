import API from '../api'

import PropertiesIndexView from '../views/properties/index_view.svelte'

export default {
  routes: [
    { path: '/admin/properties', view: PropertiesIndexView }
  ],
  getProperties: function () {
    return new Promise((resolve, reject) => {
      API.call({ url: '/api/properties' })
        .then(properties => resolve(properties))
        .catch(error => reject(error))
    })
  }
}
