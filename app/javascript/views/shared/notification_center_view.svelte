<script>
  import { onMount, onDestroy } from 'svelte'
  
  import NotificationComponent from '../../components/notification_component.svelte'

  const DEFAULT_DURATION = 3000 // 3 seconds
  let notificationListElem

  onMount(() => {
    window.addEventListener('notifications/new', handleNewNotification)
  })

  onDestroy(() => {
    window.removeEventListener('notifications/new')
  })

  function handleNewNotification (e) {
    const notificationComponent = new NotificationComponent({
      target: notificationListElem,
      props: e.detail.props
    })
    notificationComponent.$set({ me: notificationComponent })

    setTimeout(() => {
      // We need to check if the notification still exists because it might 
      // have been already closed manually by the user.
      if (notificationComponent && notificationComponent.destroy) {
        notificationComponent.destroy(notificationComponent)
      }
    }, e.detail.duration || DEFAULT_DURATION)
  }
</script>

<ul class="absolute top-3 right-4 z-50 -my-2" bind:this={notificationListElem}>
</ul>
