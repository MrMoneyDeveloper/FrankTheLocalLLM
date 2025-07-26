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
  reply.value = ''
  const resp = await fetch('/api/qa/stream', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ question: message.value })
  })
  const reader = resp.body.getReader()
  const decoder = new TextDecoder('utf-8')
  while (true) {
    const { value, done } = await reader.read()
    if (done) break
    reply.value += decoder.decode(value)
  }
}
</script>
