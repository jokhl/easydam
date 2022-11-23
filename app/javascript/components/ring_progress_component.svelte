<script>
  import { onMount } from 'svelte'

  export let progress = 0
  export function setProgress(percentage) {
    const offset = circumference - percentage * circumference
    circleElem.style.strokeDashoffset = offset
  }

  let circleElem, radius, circumference
  
  onMount(() => {
    radius = circleElem.r.baseVal.value
    circumference = radius * 2 * Math.PI
    circleElem.style.strokeDasharray = `${circumference} ${circumference}`
    circleElem.style.strokeDashoffset = `${circumference}`
    setProgress(progress) // set initial progress
  })
</script>

<style>
  .progress-animation {
    transition: 0.35s stroke-dashoffset;
    transform: rotate(-90deg);
    transform-origin: 50% 50%;
  }
</style>

<svg class="inline-block" width="16" height="16">
  <circle class="opacity-50 text-gray-400" cx="8" cy="8" r="6" stroke="currentColor" stroke-width="3" fill="transparent"></circle>
  <circle class="progress-animation text-blue-600" cx="8" cy="8" r="6" stroke="currentColor" stroke-width="3" fill="transparent" bind:this={circleElem}></circle>
</svg>
