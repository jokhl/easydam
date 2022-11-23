import TagsController from './controllers/tags_controller'

export const FILTER_FIELDS = [
  { key: 'description', icon: 'keyboard', value: 'Description', type: 'string' },
  { key: 'content-type', icon: 'picture', value: 'Media Type', type: 'list' },
  { key: 'width', icon: 'resize-full', value: 'Width', type: 'integer' },
  {
    key: 'taggings',
    icon: 'tag',
    value: 'Tag',
    type: 'list',
    params: { callback: handleTaggings }
  }
]

export const FILTER_OPERATORS_BY_TYPE = {
  string: [
    { key: '==', value: 'is exactly' },
    { key: '!=', value: 'is not' },
    { key: '~=', value: 'is approximately' }
  ],
  integer: [
    { key: '==', value: 'is exactly' },
    { key: '!=', value: 'is not' },
    { key: '>', value: 'is greater than' },
    { key: '>=', value: 'is at least' },
    { key: '<', value: 'is lesser than' },
    { key: '<=', value: 'is at most' }
  ],
  list: [
    { key: '==', value: 'is all of' },
    { key: '!=', value: 'is none of' },
    { key: '*=', value: 'is any of' }
  ],
  nested: [
    { key: '==', value: 'is all of' },
    { key: '!=', value: 'is none of' },
    { key: '*=', value: 'is any of' },
    { key: '^=', value: 'is not one of' }
  ]
}

function handleTaggings (fieldComponent) {
  fieldComponent.resetable = false
  fieldComponent.editable = true
  TagsController.getTagContexts()
    .then(data => {
      const collection = data.map(tc => {
        return {
          key: `taggings_context:${tc.key}`, // always: relation:field:value
          value: tc.label,
          icon: 'tag',
          type: 'nested'
        }
      })
      fieldComponent.collection = collection
      fieldComponent.value = ''

      // Delay the opening a little bit in case we received the data too fast
      // for the DOM.
      setTimeout(() => {
        fieldComponent.open()
      }, 200)
    })
}
