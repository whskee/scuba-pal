document.addEventListener('DOMContentLoaded', () => {
  const conversation = document.querySelector('[data-conversation-id]');
  if (!conversation) return;

  const unreadMessageCount = Number(conversation.dataset.unreadMessageCount || 0);
  document.querySelectorAll('.unread-message-badge').forEach(badge => {
    if (unreadMessageCount > 0) {
      badge.textContent = String(unreadMessageCount);
      badge.style.display = 'inline-grid';
    } else {
      badge.textContent = '';
      badge.style.display = 'none';
    }
  });
});
