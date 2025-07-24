import { mount } from '@vue/test-utils'
import Dashboard from '../../components/Dashboard.vue'
import { describe, it, expect, vi } from 'vitest'
import flushPromises from 'flush-promises'

global.fetch = vi.fn(() => Promise.resolve({
  json: () => Promise.resolve([{ id: 1, content: 'hello' }])
}))

describe('Dashboard', () => {
  it('loads items on mount', async () => {
    const wrapper = mount(Dashboard)
    await flushPromises()
    expect(wrapper.text()).toContain('hello')
    expect(fetch).toHaveBeenCalled()
  })
})
