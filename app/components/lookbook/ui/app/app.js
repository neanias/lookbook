import Router from "@js/router";
import ServerEventsListener from "@js/server_events_listener";

export default function app({ eventsEndpoint }) {
  return {
    router: null,
    serverEventsListener: null,
    sidebarPosition: Alpine.$persist(20).as("app:sidebar-position"),

    init() {
      this.router = new Router(this.$el);

      // Listen out for update events from the server
      if (eventsEndpoint) {
        this.serverEventsListener = new ServerEventsListener(eventsEndpoint);
        this.serverEventsListener.on("update", () => this.router.updatePage());
        this.serverEventsListener.start();

        addEventListener("visibilitychange", () => {
          if (!document.hidden) this.router.updatePage();
        });
      }

      this.$logger.debug("App component initialized");
    },

    hijackNavigation(event) {
      const link = event.target.closest("a[href]");
      if (link) {
        event.preventDefault();
        this.router.visit(link.href);
      }
    },

    destroy() {
      if (this.serverEventsListener) this.serverEventsListener.stop();
      this.router.cleanup();
    },
  };
}