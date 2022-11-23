<script>
  import { onMount } from 'svelte'
  import page from 'page'
  import AdminController from '../../controllers/admin_controller'

  import FormComponent from "../../components/form_component.svelte"
  import ListChooserComponent from "../../components/list_chooser_component.svelte"

  let availablePermissions, selectedPermissions
  let errorFields = [], errorMessages

  onMount(() => {
    AdminController.getPermissions()
      .then(permissions => (availablePermissions = permissions))
  })

  function handleCancel () {
    page('/admin/roles')
  }

  function handleFormSuccess () {
    page('/admin/roles')
  }

  function handleFormError (e) {
    errorFields = Object.keys(e.detail.errors)
    errorMessages = e.detail.messages
  }
</script>

<FormComponent action="/api/roles" method="post" on:success={handleFormSuccess} on:error={handleFormError}>

<div class="flex items-center justify-between w-full p-4 bg-theme-light-gray border-b">
  <h1 class="text-2xl font-bold">
    New Role
  </h1>
  <div>
    <button class="btn btn-default" on:click|preventDefault={handleCancel}>
      Cancel
    </button>
    <button type="submit" class="btn btn-positive">
      Create
    </button>
  </div>
</div>

{#if errorMessages}
  <div class="w-1/3 mt-3 mb-2 px-4">
    <h5 class="mb-1 font-medium text-red-600">{errorMessages.length} error(s):</h5>
    <ul class="w-full py-1 px-2 bg-red-100 border rounded-md list-decimal list-inside border-red-600 text-red-600 text-sm">
      {#each errorMessages as message}
        <li>{message}</li>
      {/each}
    </ul>
  </div>
{/if}

<fieldset class="flex flex-wrap w-1/3 mt-3 px-4">
  <div class="form-group">
    <label for="name">Name</label>
    <input name="role[name]" type="text" class="form-control" class:border-red-600={errorFields.includes('name')}>
  </div>
  <div class="flex-grow form-group">
    <label for="description">Description</label>
    <input name="role[description]" type="text" class="form-control" class:border-red-600={errorFields.includes('description')}>
  </div>
</fieldset>

<div class="px-4 form-group">
  <label>Permissions</label>
  <ListChooserComponent leftTitle="Available permissions" leftList={availablePermissions} rightTitle="Selected permissions" keyField="id" valueField="key" isForm={true} name="role[permissions][]" listsClass={errorFields.includes('permissions') ? 'border-red-600' : ''} />
</div>

</FormComponent>
