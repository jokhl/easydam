export default {
  call: function (opts) {
    const config = {
      headers: {
        'Content-Type': 'application/json'
      },
      method: opts.method || 'GET'
    }

    if (opts.body) config.body = opts.body

    return new Promise((resolve, reject) => {
      fetch(opts.url, config)
        .then(async res => {
          const data = await res.json()
          if (res.ok) resolve(data)
          else reject(data)
        })
        .catch(error => console.error(error))
    })
  },
  post: function (opts) {
    return new Promise((resolve, reject) => {
      const csrfToken = document.querySelector('meta[name="csrf-token"]').content
      const body = {
        authenticity_token: csrfToken,
        ...opts.body
      }

      fetch(opts.url, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(body)
      }).then(async res => {
        const data = await res.json()

        if (res.ok) resolve(data)
        else reject(data)
      })
    })
  }
}
