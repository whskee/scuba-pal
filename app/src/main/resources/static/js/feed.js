document.addEventListener('submit', async (event) => {
  const form = event.target.closest('.like-form');
  if (!form) return;
  event.preventDefault();
  const button = form.querySelector('button');
  const csrf = form.querySelector('input[type="hidden"]');
  button.disabled = true;
  try {
    const headers = { 'X-Requested-With': 'fetch', 'Accept': 'application/json' };
    if (csrf && csrf.name && csrf.value) {
      headers['X-CSRF-TOKEN'] = csrf.value;
    }
    const response = await fetch(form.action, {
      method: 'POST',
      credentials: 'same-origin',
      headers
    });
    if (!response.ok || !response.headers.get('content-type')?.includes('application/json')) {
      window.location.href = response.url || '/login';
      return;
    }
    const post = await response.json();
    const card = form.closest('[data-post-id]');
    card.querySelector('[data-like-count]').textContent = post.likes;
    button.classList.toggle('is-liked', post.likedByCurrentUser);
    button.setAttribute('aria-pressed', String(post.likedByCurrentUser));
    button.setAttribute('aria-label', post.likedByCurrentUser ? 'Unlike post' : 'Like post');
    const label = button.querySelector('.heart-button__text');
    if (label) {
      label.textContent = post.likedByCurrentUser ? 'Liked' : 'Like';
    }
  } catch {
    form.submit();
  } finally {
    button.disabled = false;
  }
});
