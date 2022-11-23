<script>
  import { onMount, createEventDispatcher } from 'svelte'
  import { notify } from '../utilities'

  export let action
  export let method
  export let formElem
  export let className = ''
  
  let csrfToken
  const dispatch = createEventDispatcher()

  onMount(() => {
    csrfToken = document.querySelector('meta[name="csrf-token"]').content
  })

  function onSubmit (e) {
    e.preventDefault()
    fetch(e.target.action, {
      method: e.target.method,
      body: new FormData(formElem)
    })
    .then(async res => {
      console.log(res.status)
      if (res.ok) dispatch('success', await res.json())
      else dispatch('error', await res.json())
    })
    .catch(error => {
      console.error(error)
      notify({
        duration: 5000,
        props: {
          title: 'Error',
          subtitle: 'Could not contact server.',
          status: 'error'
        }
      })
    })
  }
</script>

<form action="{action}" method="{method}" class="{className}" accept-charset="UTF-8" on:submit={onSubmit} bind:this={formElem}>
  <input type="hidden" name="authenticity_token" value="{csrfToken}">
  <slot />
</form>
