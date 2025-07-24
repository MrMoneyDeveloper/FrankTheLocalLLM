<template>
  <div>
    <input v-model="message" placeholder="Say hi" />
    <button @click="send">Send</button>
    <p v-if="reply">{{ reply }}</p>
  </div>
</template>
<script setup>
import { ref } from 'vue'
const message = ref('')
const reply = ref('')
async function send() {
  const resp = await fetch('/api/chat', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ message: message.value })
  })
  const data = await resp.json()
  reply.value = data.response
}
</script>
