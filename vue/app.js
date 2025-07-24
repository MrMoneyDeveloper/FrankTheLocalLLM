const { createApp } = Vue;

createApp({
  data() {
    return {
      username: '',
      password: '',
      loading: false,
      error: null,
      success: false
    };
  },
  methods: {
    async submit() {
      this.error = null;
      if (!this.username || !this.password) {
        this.error = 'Username and password required';
        return;
      }
      this.loading = true;
      try {
        const resp = await fetch('http://localhost:8000/api/auth/login', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ username: this.username, password: this.password })
        });
        if (resp.ok) {
          const data = await resp.json();
          localStorage.setItem('token', data.access_token);
          this.success = true;
        } else {
          this.error = 'Login failed';
        }
      } catch (err) {
        this.error = 'Login failed';
      }
      this.loading = false;
    }
  }
}).mount('#app');
