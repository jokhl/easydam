import { quadInOut } from 'svelte/easing'

export function reveal (node, params) {
  const {
    delay = 0,
    duration = 300,
    easing = quadInOut,
    horizontal = false,
    vertical = false,
    opacity = false
  } = params

  const w = parseFloat(getComputedStyle(node).strokeWidth)

  return {
    delay,
    duration,
    easing,
    css: t => {
      let css = opacity ? `opacity: ${t};` : ''
      if (horizontal) css += `width: ${t * 100}%;`
      if (vertical) css += `height: ${t * 100}%;`
      return css
    }
  }
}
