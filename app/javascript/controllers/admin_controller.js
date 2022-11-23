import API from '../api'

import RolesIndexView from '../views/roles/index_view.svelte'
import RolesNewView from '../views/roles/new_view.svelte'
import UsersIndexView from '../views/users/index_view.svelte'
import UsersNewView from '../views/users/new_view.svelte'
import UsersShowView from '../views/users/show_view.svelte'

export default {
  routes: [
    { path: '/admin/roles', view: RolesIndexView },
    { path: '/admin/roles/new', view: RolesNewView },
    { path: '/admin/users', view: UsersIndexView },
    { path: '/admin/users/new', view: UsersNewView },
    { path: '/admin/users/:userID', view: UsersShowView }
  ],
  getPermissions: function () {
    return new Promise((resolve, reject) => {
      API.call({ url: '/api/permissions' })
        .then(permissions => resolve(permissions))
        .catch(error => console.error(error))
    })
  },
  getRoles: function () {
    return new Promise((resolve, reject) => {
      API.call({ url: '/api/roles' })
        .then(roles => resolve(roles))
        .catch(error => console.error(error))
    })
  },
  getUsers: function () {
    return new Promise((resolve, reject) => {
      API.call({ url: '/api/users' })
        .then(users => resolve(users))
        .catch(error => console.error(error))
    })
  },
  getUser: function (userID) {
    return new Promise((resolve, reject) => {
      API.call({ url: `/api/users/${userID}` })
        .then(users => resolve(users))
        .catch(error => console.error(error))
    })
  }
}
