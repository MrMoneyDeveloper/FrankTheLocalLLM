<template>
  <div>
    <h1>Dashboard</h1>
    <ul>
      <li v-for="item in items" :key="item.id">{{ item.content }}</li>
    </ul>
  </div>
</template>
<script setup>
import { ref, onMounted } from 'vue'
const items = ref([])
onMounted(async () => {
  const resp = await fetch('/api/entries')
  items.value = await resp.json()
})
</script>
