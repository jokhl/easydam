<script>
  import { onMount } from 'svelte'

  export let className = ''
  export let inputName = ''
  export let options = []
  export let value
  export function getValue () {
    return value
  }

  let sliderElem, leftRadioElem, leftLabelElem, rightRadioElem, rightLabelElem

  onMount(() => {
    // We need to make this call in order to set the initial value when the
    // component is mounted.
    handleChange()
  })

  function handleChange () {
    if (rightRadioElem.checked) {
      sliderElem.classList.add('translate-x-full')
      value = rightRadioElem.value
    } else {
      sliderElem.classList.remove('translate-x-full')
      value = leftRadioElem.value
    }
  }
</script>

<style>
  input[type='radio']:checked + label {
    color: #ffffff;
  }

  input[type='radio']:not(:checked) + label {
    cursor: pointer;
  }
</style>

<div class="{className} bg-white border border-gray-300 rounded-md leading-none" style="padding: 2px;">
  <div class="relative flex items-center w-full">
    <span class="absolute block z-0 w-1/2 h-full bg-blue-500 rounded-md shadow transition-all duration-300 transform-gpu" bind:this={sliderElem}></span>
    <input id="{inputName}[0]" class="hidden" name="{inputName}" value="{options[0].key}" type="radio" checked bind:this={leftRadioElem} on:change={handleChange}>
    <label for="{inputName}[0]" class="inline-block z-1 w-1/2 py-1 text-gray-600 text-xs font-medium text-center transition-colors duration-200" bind:this={leftLabelElem}>
      {options[0].value}
    </label>
    <input id="{inputName}[1]" class="hidden" name="{inputName}" value="{options[1].key}" type="radio" bind:this={rightRadioElem} on:change={handleChange}>
    <label for="{inputName}[1]" class="inline-block z-1 w-1/2 py-1 text-gray-600 text-xs font-medium text-center transition-colors duration-200" bind:this={rightLabelElem}>
      {options[1].value}
    </label>
  </div>
</div>
