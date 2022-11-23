<script>
  import { onMount, onDestroy } from 'svelte'
  import { DateTime } from 'luxon'

  import AdminController from '../../controllers/admin_controller'

  export let userID

  let user, roles = ''

  $: if (user) {
    roles = user.roles
      .filter(role => role.system_role)
      .map(role => role.name)
      .join(', ')
  }

  onMount(() => {
    console.log(userID)
    AdminController.getUser(userID)
      .then(data => (user = data))
  })

  onDestroy(() => {
  })

  function getHumanDate (isoDate) {
    const dt = DateTime.fromISO(isoDate)
    return dt.toLocaleString(DateTime.DATETIME_FULL)
  }
</script>

<div class="flex items-center justify-between w-full p-4">
  <h1 class="text-2xl font-bold">
    User Profile
  </h1>
  <a href="/admin/users/new" class="btn btn-default">
    <span class="inline-block mr-1 icon icon-pencil"></span> Edit
  </a>
</div>

{#if user}
  <div class="mt-3 px-4">
    <ul class="w-1/3 border rounded-md text-sm">
      <li class="flex border-b">
        <div class="w-1/3 py-1 px-4 bg-theme-light-gray text-right font-medium text-gray-500">
          Name
        </div>
        <div class="py-1 px-4">{user.name}</div>
      </li>
      <li class="flex border-b">
        <div class="w-1/3 py-1 px-4 bg-theme-light-gray text-right font-medium text-gray-500">
          Username
        </div>
        <div class="py-1 px-4">{user.login}</div>
      </li>
      <li class="flex border-b">
        <div class="w-1/3 py-1 px-4 bg-theme-light-gray text-right font-medium text-gray-500">
          E-mail
        </div>
        <div class="py-1 px-4">{user.email}</div>
      </li>
      <li class="flex">
        <div class="w-1/3 py-1 px-4 bg-theme-light-gray text-right font-medium text-gray-500">
          Roles
        </div>
        <div class="py-1 px-4">
          {roles}
        </div>
      </li>
    </ul>
  </div>
{/if}
