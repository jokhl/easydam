import API from '../api'

export default {
  search: function (query, page = 1) {
    return new Promise((resolve, reject) => {
      API.post({
        url: `/api/search?page=${page}`,
        body: {
          query: query
        }
      })
        .then(results => resolve(results))
        .catch(error => reject(error))
    })
  }
}
