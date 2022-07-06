import consumer from "./consumer"

consumer.subscriptions.create("QuestionsChannel", {
  connected() {
    this.perform('follow')
  },

  disconnected() {
  },

  recieved(data) {
    $('.questions').append(data)
  }
});
