<script>
  import key from './key.vue';

  export default {
    props: {
      title: {
        type: String,
        required: true,
      },
      keys: {
        type: Array,
        required: true,
      },
      showHelpBox: {
        type: Boolean,
        required: false,
        default: true,
      },
      store: {
        type: Object,
        required: true,
      },
    },
    components: {
      key,
    },
  };
</script>

<template>
  <div class="deploy-keys-panel">
    <h5>
      {{ title }}
      ({{ keys.length }})
    </h5>
    <ul class="well-list"
      v-if="keys.length">
      <li
        v-for="deployKey in keys"
        :key="deployKey.id">
        <key
          :deploy-key="deployKey"
          :store="store" />
      </li>
    </ul>
    <div
      class="settings-message text-center"
      v-else-if="showHelpBox">
      No deploy keys found. Create one with the form above.
    </div>
  </div>
</template>
