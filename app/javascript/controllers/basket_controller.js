import API from '../api'

export default {
  getTagContexts: function () {
    return new Promise((resolve, reject) => {
      API.call({ url: '/api/tag_contexts' })
        .then(tagContexts => resolve(tagContexts))
        .catch(error => reject(error))
    })
  },
  addToBasket: function (assets) {
    return new Promise((resolve, reject) => {
      API.post({
        url: '/basket/add',
        body: {
          tag_context: {
            label: label
          }
        }
      })
        .then(newTagContext => resolve(newTagContext))
        .catch(error => reject(error))
    })
  }
}
