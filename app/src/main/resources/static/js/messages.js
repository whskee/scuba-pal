document.addEventListener('DOMContentLoaded', () => {
  const conversation = document.querySelector('[data-conversation-id]');
  if (!conversation) return;

  const messageList = document.querySelector('[data-message-list]');
  const form = document.querySelector('[data-message-form]');
  const textarea = form ? form.querySelector('textarea[name="messageText"]') : null;
  const submitButton = form ? form.querySelector('button[type="submit"]') : null;
  const messagesUrl = conversation.dataset.messagesUrl;
  const sendUrl = conversation.dataset.sendUrl;

  function parseApiDate(value) {
    if (!value) return new Date();
    if (/^\d{4}-\d{2}-\d{2}$/.test(value)) return new Date(`${value}T00:00:00`);
    return new Date(value);
  }

  function formatReadAt(value) {
    const date = parseApiDate(value);
    return new Intl.DateTimeFormat(undefined, {
      month: 'short',
      day: 'numeric',
      year: 'numeric',
      hour: 'numeric',
      minute: '2-digit'
    }).format(date);
  }

  function updateUnreadBadge(unreadMessageCount) {
    document.querySelectorAll('.unread-message-badge').forEach(badge => {
      if (unreadMessageCount > 0) {
        badge.textContent = String(unreadMessageCount);
        badge.style.display = 'inline-grid';
      } else {
        badge.textContent = '';
        badge.style.display = 'none';
      }
    });
  }

  function avatarFor(message) {
    if (message.sentByCurrentUser) return null;
    if (message.senderProfileImageUrl) {
      const img = document.createElement('img');
      img.className = 'message-avatar';
      img.src = message.senderProfileImageUrl;
      img.alt = '';
      return img;
    }
    const fallback = document.createElement('span');
    fallback.className = 'message-avatar';
    fallback.textContent = (message.senderUsername || 'D').substring(0, 1).toUpperCase();
    return fallback;
  }

  function renderMessages(messages) {
    if (!messageList) return;
    const wasNearBottom = window.innerHeight + window.scrollY >= document.body.scrollHeight - 160;
    messageList.replaceChildren();

    if (!messages.length) {
      const empty = document.createElement('p');
      empty.className = 'muted';
      empty.dataset.emptyMessages = '';
      empty.textContent = 'No messages yet.';
      messageList.appendChild(empty);
      return;
    }

    messages.forEach(message => {
      const row = document.createElement('div');
      row.className = `message-row${message.sentByCurrentUser ? ' mine' : ''}`;
      const avatar = avatarFor(message);
      if (avatar) row.appendChild(avatar);

      const bubble = document.createElement('div');
      bubble.className = 'message-bubble';

      const sender = document.createElement('strong');
      sender.textContent = message.senderUsername || 'diver';
      const body = document.createElement('p');
      body.textContent = message.messageText || '';
      const status = document.createElement('small');
      status.className = 'muted';
      if (message.sentByCurrentUser && message.readAt) {
        status.textContent = `Read at ${formatReadAt(message.readAt)}`;
      } else if (message.sentByCurrentUser) {
        status.textContent = 'Sent';
      } else {
        status.textContent = '';
      }

      bubble.append(sender, body);
      if (status.textContent) bubble.appendChild(status);
      row.appendChild(bubble);
      messageList.appendChild(row);
    });

    if (wasNearBottom) {
      window.scrollTo({ top: document.body.scrollHeight, behavior: 'smooth' });
    }
  }

  async function refreshMessages() {
    if (!messagesUrl) return;
    const response = await fetch(messagesUrl, {
      headers: { Accept: 'application/json' },
      credentials: 'same-origin'
    });
    if (!response.ok) return;
    const payload = await response.json();
    renderMessages(payload.messages || []);
    updateUnreadBadge(Number(payload.unreadMessageCount || 0));
  }

  updateUnreadBadge(Number(conversation.dataset.unreadMessageCount || 0));

  if (form && textarea && sendUrl) {
    form.addEventListener('submit', async event => {
      event.preventDefault();
      const messageText = textarea.value.trim();
      if (!messageText) return;
      if (submitButton) submitButton.disabled = true;

      try {
        const body = new URLSearchParams({ messageText });
        const response = await fetch(sendUrl, {
          method: 'POST',
          headers: { Accept: 'application/json', 'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8' },
          body,
          credentials: 'same-origin'
        });
        if (!response.ok) throw new Error('Send failed');
        textarea.value = '';
        const payload = await response.json();
        renderMessages(payload.messages || []);
        updateUnreadBadge(Number(payload.unreadMessageCount || 0));
      } finally {
        if (submitButton) submitButton.disabled = false;
      }
    });
  }

  refreshMessages();
  window.setInterval(refreshMessages, 3000);
});
