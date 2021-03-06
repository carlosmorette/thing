// We import the CSS which is extracted to its own file by esbuild.
// Remove this line if you add a your own CSS build pipeline (e.g postcss).
import "../css/app.css"

// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "./vendor/some-package.js"
//
// Alternatively, you can `npm install some-package` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

let Hooks = {}

Hooks.SignUpButton = {
  mounted() {
		this.handleEvent("new-subscriber", ({ nickname }) => {
	  	sessionStorage.setItem("nickname", nickname)
			this.pushEvent("hook:signup-button:registered", { nickname })
		})
  }
}

Hooks.HomeLive = {
  mounted() {
		this.pushEvent("hook:home-live:mounted", {nickname: sessionStorage.getItem("nickname")})
	
		this.handleEvent("new-room", ({ room_name }) => {
			sessionStorage.setItem("roomName", room_name)
			this.pushEvent("hook:home-live:created-room", { room_name })
		})  
	}
}

Hooks.ChatLive = {
	mounted() {
		nickname = sessionStorage.getItem("nickname")
		roomName = sessionStorage.getItem("roomName")
		this.pushEvent("hook:chat-live:mounted", {nickname, room_name: roomName})

		this.handleEvent("new-message", () => {
			window.scrollTo(0, document.body.scrollHeight);
		})
		this.handleEvent("joined-chat", () => {
	    window.scrollTo(0, document.body.scrollHeight);
		})
  }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {hooks: Hooks, params: {_csrf_token: csrfToken}})

liveSocket.disableDebug()

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show())
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket
