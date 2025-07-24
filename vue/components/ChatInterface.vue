<template>
  <div>
    <input v-model="message" placeholder="Say hi" />
    <button @click="send">Send</button>
    <p v-if="reply">{{ reply }}</p>
  </div>
</template>
<script setup>
import { ref } from 'vue'
import { useFetch } from '../composables/useFetch'

const message = ref('')
const reply = ref('')

const { data, fetchData } = useFetch(
  '/api/chat',
  { method: 'POST', headers: { 'Content-Type': 'application/json' } },
  { debounce: 0 }
)

async function send() {
  await fetchData({ body: JSON.stringify({ message: message.value }) })
  if (data.value) {
    reply.value = data.value.response
  }
}
</script>
