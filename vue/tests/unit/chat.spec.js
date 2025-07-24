import { mount } from '@vue/test-utils'
import ChatInterface from '../../components/ChatInterface.vue'
import { describe, it, expect, vi } from 'vitest'

global.fetch = vi.fn(() => Promise.resolve({
  json: () => Promise.resolve({ response: 'hi there' })
}))

describe('ChatInterface', () => {
  it('sends message and shows reply', async () => {
    const wrapper = mount(ChatInterface)
    await wrapper.find('input').setValue('hello')
    await wrapper.find('button').trigger('click')
    await wrapper.vm.$nextTick()
    expect(wrapper.text()).toContain('hi there')
    expect(fetch).toHaveBeenCalled()
    expect(wrapper.html()).toMatchSnapshot()
  })
})
