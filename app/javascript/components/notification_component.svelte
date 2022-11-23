<script>
  import { onMount } from 'svelte'

  const DEFAULT_ANIMATION_DURATION = 300

  export let className = ''
  export let title = ''
  export let subtitle = ''
  export let animationDuration = DEFAULT_ANIMATION_DURATION
  export let status = 'normal'
  export let icon
  export let me
  export let truncate = true

  let notificationElem, subtitleElem, destroying = false

  // The 'me' param is the current component instance.
  export function destroy () {
    if (!destroying) {
      destroying = true
      notificationElem.classList.add('translate-x-96')
      setTimeout(() => {
        notificationElem.classList.remove('active')
        setTimeout(() => {
          me.$destroy()
        }, animationDuration + 100)
      }, animationDuration)
    }
  }

  onMount(() => {
    subtitleElem.innerHTML = format(subtitle)
    notificationElem.classList.add('active')
    setTimeout(() => notificationElem.classList.remove('translate-x-96'), 100)
  })

  function format (str) {
    return str.replace(/\*\*(.*)\*\*/gm, '<span class="font-semibold">$1</span>')
  }
</script>

<li class="translate-x-96 duration-{animationDuration} notification" bind:this={notificationElem}>
  <div class="flex w-full bg-gray-100 blur-md border rounded-md shadow-md opacity-95 {className}" class:h-16={truncate}>
    <div class="py-3 pl-4">
      {#if status === 'success'}
        <span class="py-1 px-2 bg-green-200 rounded-md text-green-600 icon icon-check"></span>
      {:else if status === 'error'}
        <span class="py-1 px-2 bg-red-200 rounded-md text-red-600 icon icon-cancel"></span>
      {:else if status === 'warning'}
        <span class="py-1 px-2 bg-yellow-200 rounded-md text-yellow-400 icon icon-attention"></span>
      {:else}
        {icon}
      {/if}
    </div>
    <div class="flex-grow py-3 px-4 overflow-hidden">
      <span class="block w-full text-sm text-gray-700 font-semibold leading-none" class:truncate>{title}</span>
      <span class="block w-full mt-1.5 text-xs text-gray-500 font-light" class:truncate bind:this={subtitleElem}></span>
    </div>
    <div class="border-l text-center text-sm font-light text-gray-700">
      <button class="w-full h-full px-4 outline-none active:bg-blue-500 active:text-white active:outline-none" on:click={destroy}>
        Close
      </button>
    </div>
  </div>
</li>
