import API from '../api'

export default {
  getTagContexts: function () {
    return new Promise((resolve, reject) => {
      API.call({ url: '/api/tag_contexts' })
        .then(tagContexts => resolve(tagContexts))
        .catch(error => reject(error))
    })
  },
  getAssetTags: function (assetID) {
    return new Promise((resolve, reject) => {
      API.call({ url: `/api/assets/${assetID}/tags` })
        .then(tags => resolve(tags))
        .catch(error => reject(error))
    })
  },
  getTagContext: function (contextID) {
    return new Promise((resolve, reject) => {
      API.call({ url: `/api/tag_contexts/${contextID}` })
        .then(tagContext => resolve(tagContext))
        .catch(error => reject(error))
    })
  },
  createTagContext: function (label) {
    return new Promise((resolve, reject) => {
      API.post({
        url: '/api/tag_contexts',
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
