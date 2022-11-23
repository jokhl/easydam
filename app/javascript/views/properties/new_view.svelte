<script>
  import { onMount, createEventDispatcher } from 'svelte'
  import page from 'page'
  import { notify } from '../../utilities'

  import FormComponent from '../../components/form_component.svelte'

  const dispatch = createEventDispatcher()

  let errorFields = []
  let propertyName = ''

  onMount(() => {
  })

  function handleCancel () {
    dispatch('closeWindow')
  }

  function handleFormSuccess () {
    dispatch('closeWindow')
    page('/admin/properties')
    notify({
      duration: 5000,
      props: {
        title: 'Success',
        subtitle: `Property **${propertyName}** created.`,
        status: 'success',
        truncate: false
      }
    })
  }

  function handleFormError (e) {
    errorFields = e.detail.error_fields
    const errorMessages = e.detail.error_messages
    errorMessages.forEach(msg => {
      notify({
        duration: 5000,
        props: {
          title: 'Error',
          subtitle: msg,
          status: 'error',
          truncate: false
        }
      })
    })
  }
</script>

<FormComponent action="/api/properties" method="post" on:success={handleFormSuccess} on:error={handleFormError}>

<fieldset class="flex flex-wrap w-full py-3 px-4">
  <div class="w-full form-group">
    <label for="name">Name</label>
    <input name="property[name]" type="text" class="w-full form-control" class:border-red-600={errorFields.includes('name')} bind:value={propertyName}>
  </div>

  <div class="w-full form-group">
    <label for="description">Type</label>
    <select name="property[prop_type]" id="property[prop_type]" class="w-full form-control">
      <option value="Text">Text</option>
      <option value="Date">Date</option>
      <option value="Number">Number</option>
    </select>
  </div>
</fieldset>

<div class="w-full pb-4 text-center">
  <button class="btn btn-default" on:click|preventDefault={handleCancel}>
    Cancel
  </button>
  <button type="submit" class="ml-2 btn btn-primary">
    Add property
  </button>
</div>

</FormComponent>
