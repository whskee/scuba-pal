document.addEventListener('submit', async (event) => {
  const form = event.target.closest('.like-form');
  if (!form) return;
  event.preventDefault();
  const response = await fetch(form.action, { method: 'POST', headers: { 'X-Requested-With': 'fetch' } });
  if (!response.ok) { form.submit(); return; }
  const post = await response.json();
  const card = form.closest('[data-post-id]');
  card.querySelector('[data-like-count]').textContent = post.likes;
  const button = form.querySelector('button');
  button.textContent = post.likedByCurrentUser ? 'Unlike' : 'Like';
});
