<template>
  <div class="p-2">
    <ul>
      <li v-for="f in files" :key="f.id">{{ f.name }}</li>
    </ul>
    <!-- placeholder for backlink mini-graph -->
    <div class="mt-4 h-40 border">Graph</div>
  </div>
</template>
<script setup>
import { onMounted, ref } from 'vue'
import { useFetch } from '../composables/useFetch'

const { data: files, fetchData } = useFetch('/api/entries')

onMounted(() => fetchData())
</script>
